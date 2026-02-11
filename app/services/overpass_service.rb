class OverpassService
  OVERPASS_URL = 'https://overpass-api.de/api/interpreter'.freeze

  CATEGORY_TAGS = {
    'bus_stops' => [
      '["highway"="bus_stop"]'
    ],
    'stations' => [
      '["railway"~"station|subway_entrance|tram_stop|halt"]',
      '["public_transport"="station"]'
    ],
    'coffee' => [
      '["amenity"="cafe"]',
      '["cuisine"="coffee"]'
    ],
    'grocery' => [
      '["shop"~"supermarket|grocery|convenience"]'
    ],
    'gym' => [
      '["leisure"="fitness_centre"]',
      '["amenity"="gym"]'
    ],
    'food' => [
      '["amenity"="restaurant"]'
    ],
    'coworking' => [
      '["amenity"="coworking_space"]',
      '["office"="coworking"]'
    ],
    'library' => [
      '["amenity"="library"]'
    ],
    'parks' => [
      '["leisure"="park"]',
      '["leisure"="garden"]'
    ]
  }.freeze

  TRANSIT_ROUTE_TYPES = {
    'rails' => %w[subway tram light_rail railway],
    'train' => %w[train],
    'ferry' => %w[ferry],
    'bus' => %w[bus]
  }.freeze

  class << self
    def fetch_pois(lat:, lng:, category:, radius: 1000)
      return [] unless CATEGORY_TAGS.key?(category)

      query = build_poi_query(lat, lng, category, radius)
      Rails.logger.info("Overpass POI query: #{query}")
      response = make_request(query)
      parse_poi_response(response, lat, lng)
    end

    def fetch_transit_routes(lat:, lng:, route_type:, radius: 2000)
      return [] unless TRANSIT_ROUTE_TYPES.key?(route_type)

      query = build_transit_query(lat, lng, route_type, radius)
      Rails.logger.info("Overpass transit query: #{query}")
      response = make_request(query)
      parse_transit_response(response)
    end

    private

    def build_poi_query(lat, lng, category, radius)
      tags = CATEGORY_TAGS[category]
      bbox = calculate_bbox(lat, lng, radius)

      node_queries = tags.map { |tag| "node#{tag}(#{bbox});" }.join("\n    ")

      <<~QUERY
        [out:json][timeout:25];
        (
          #{node_queries}
        );
        out body;
      QUERY
    end

    def build_transit_query(lat, lng, route_type, radius)
      bbox = calculate_bbox(lat, lng, radius)
      osm_route_types = TRANSIT_ROUTE_TYPES[route_type]
      relation_queries = osm_route_types.map { |t| "relation[\"route\"=\"#{t}\"](#{bbox});" }.join("\n          ")

      <<~QUERY
        [out:json][timeout:30];
        (
          #{relation_queries}
        );
        out body;
        >;
        out skel qt;
      QUERY
    end

    def calculate_bbox(lat, lng, radius)
      lat_delta = radius / 111_000.0
      lng_delta = radius / (111_000.0 * Math.cos(lat * Math::PI / 180))

      south = lat - lat_delta
      north = lat + lat_delta
      west = lng - lng_delta
      east = lng + lng_delta

      "#{south},#{west},#{north},#{east}"
    end

    def make_request(query)
      response = HTTParty.post(
        OVERPASS_URL,
        body: { data: query },
        headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
        timeout: 30
      )

      unless response.success?
        Rails.logger.error("Overpass API returned #{response.code}: #{response.body[0..200]}")
        return nil
      end

      JSON.parse(response.body)
    rescue StandardError => e
      Rails.logger.error("Overpass API error: #{e.message}")
      nil
    end

    def parse_poi_response(response, origin_lat, origin_lng)
      return [] unless response && response['elements']

      response['elements'].map do |element|
        next unless element['lat'] && element['lon']

        tags = element['tags'] || {}

        {
          name: tags['name'],
          latitude: element['lat'],
          longitude: element['lon'],
          osm_id: "#{element['type']}/#{element['id']}",
          address: build_address(tags),
          opening_hours: tags['opening_hours'],
          distance_meters: calculate_distance(
            origin_lat, origin_lng,
            element['lat'], element['lon']
          ),
          website: tags['website'] || tags['contact:website'],
          phone: tags['phone'] || tags['contact:phone'],
          cuisine: tags['cuisine'],
          outdoor_seating: tags['outdoor_seating'] == 'yes',
          internet_access: tags['internet_access'],
          air_conditioning: tags['air_conditioning'] == 'yes',
          takeaway: tags['takeaway'] == 'yes',
          brand: tags['brand'],
          description: tags['description'],
          wikidata: tags['wikidata']
        }
      end.compact
    end

    def parse_transit_response(response)
      return [] unless response && response['elements']

      nodes = {}
      ways = {}
      relations = []

      # Phase 1: Index all nodes and ways
      response['elements'].each do |element|
        case element['type']
        when 'node'
          nodes[element['id']] = [element['lat'], element['lon']]
        when 'way'
          ways[element['id']] = element['nodes'] || []
        when 'relation'
          relations << element
        end
      end

      # Phase 2: Process each relation
      relations.map do |relation|
        build_route_geometry(relation, ways, nodes)
      end.compact
    end

    def build_route_geometry(relation, ways, nodes)
      members = relation['members'] || []

      # Extract way members with their geometries
      way_segments = extract_way_segments(members, ways, nodes)
      return nil if way_segments.empty?

      # Stitch ways into continuous paths
      stitched_paths = stitch_ways(way_segments)
      return nil if stitched_paths.empty?

      {
        name: relation.dig('tags', 'name') || relation.dig('tags', 'ref'),
        osm_id: "relation/#{relation['id']}",
        color: relation.dig('tags', 'colour') || relation.dig('tags', 'color'),
        geometry: stitched_paths  # Now an array of paths (each path is array of [lat, lng])
      }
    end

    def extract_way_segments(members, ways, nodes)
      members.filter_map do |member|
        next unless member['type'] == 'way' && ways[member['ref']]

        node_ids = ways[member['ref']]
        coords = node_ids.map { |id| nodes[id] }.compact
        next if coords.length < 2

        {
          id: member['ref'],
          coords: coords,
          start_coord: coords.first,
          end_coord: coords.last
        }
      end
    end

    def stitch_ways(way_segments)
      return [] if way_segments.empty?

      # Build endpoint index: coord_key -> [segments that start/end here]
      endpoint_index = build_endpoint_index(way_segments)

      # Track which segments we've used
      used = Set.new
      paths = []

      # Process each unused segment as a potential path start
      way_segments.each do |segment|
        next if used.include?(segment[:id])

        path = build_path_from(segment, endpoint_index, used)
        paths << path if path.length >= 2
      end

      paths
    end

    def build_endpoint_index(way_segments)
      index = Hash.new { |h, k| h[k] = [] }

      way_segments.each do |seg|
        start_key = coord_key(seg[:start_coord])
        end_key = coord_key(seg[:end_coord])

        # Only index if we have valid coordinate keys
        index[start_key] << { segment: seg, is_start: true } if start_key
        index[end_key] << { segment: seg, is_start: false } if end_key
      end

      index
    end

    def build_path_from(start_segment, endpoint_index, used)
      path = start_segment[:coords].dup
      used.add(start_segment[:id])
      current_end = start_segment[:end_coord]

      # Keep extending the path while we find connected segments
      loop do
        next_segment = find_connected_segment(current_end, endpoint_index, used)
        break unless next_segment

        seg = next_segment[:segment]
        used.add(seg[:id])

        # Add coords (possibly reversed) excluding the shared point
        if next_segment[:is_start]
          # Segment starts at our current end - add in order, skip first point
          path.concat(seg[:coords][1..])
          current_end = seg[:end_coord]
        else
          # Segment ends at our current end - add reversed, skip first point
          path.concat(seg[:coords][0..-2].reverse)
          current_end = seg[:start_coord]
        end
      end

      path
    end

    def find_connected_segment(coord, endpoint_index, used)
      key = coord_key(coord)
      candidates = endpoint_index[key] || []
      candidates.find { |c| !used.include?(c[:segment][:id]) }
    end

    def coord_key(coord)
      # Round to ~1 meter precision to handle floating point differences
      "#{coord[0].round(5)},#{coord[1].round(5)}"
    end

    def build_address(tags)
      return nil unless tags

      parts = [
        tags['addr:housenumber'],
        tags['addr:street'],
        tags['addr:city']
      ].compact

      parts.any? ? parts.join(' ') : nil
    end

    def calculate_distance(lat1, lng1, lat2, lng2)
      r = 6_371_000

      phi1 = lat1 * Math::PI / 180
      phi2 = lat2 * Math::PI / 180
      delta_phi = (lat2 - lat1) * Math::PI / 180
      delta_lambda = (lng2 - lng1) * Math::PI / 180

      a = Math.sin(delta_phi / 2)**2 +
          Math.cos(phi1) * Math.cos(phi2) * Math.sin(delta_lambda / 2)**2
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

      (r * c).round
    end
  end
end
