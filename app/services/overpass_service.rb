class OverpassService
  OVERPASS_URL = 'https://overpass-api.de/api/interpreter'.freeze

  CATEGORY_QUERIES = {
    'transit_stops' => 'node["public_transport"="stop_position"]; node["highway"="bus_stop"]; node["railway"~"station|subway_entrance|tram_stop"];',
    'coffee' => 'node["amenity"="cafe"]; node["cuisine"="coffee"];',
    'veterinarian' => 'node["amenity"="veterinary"];',
    'grocery' => 'node["shop"~"supermarket|grocery|convenience"];'
  }.freeze

  TRANSIT_ROUTE_QUERIES = {
    'subway' => 'relation["route"="subway"];',
    'tram' => 'relation["route"="tram"];',
    'bus' => 'relation["route"="bus"];'
  }.freeze

  class << self
    def fetch_pois(lat:, lng:, category:, radius: 1000)
      return [] unless CATEGORY_QUERIES.key?(category)

      query = build_poi_query(lat, lng, category, radius)
      response = make_request(query)
      parse_poi_response(response, lat, lng)
    end

    def fetch_transit_routes(lat:, lng:, route_type:, radius: 2000)
      return [] unless TRANSIT_ROUTE_QUERIES.key?(route_type)

      query = build_transit_query(lat, lng, route_type, radius)
      response = make_request(query)
      parse_transit_response(response)
    end

    private

    def build_poi_query(lat, lng, category, radius)
      bbox = calculate_bbox(lat, lng, radius)
      category_query = CATEGORY_QUERIES[category]

      <<~QUERY
        [out:json][timeout:25];
        (
          #{category_query}
        )(#{bbox});
        out body;
      QUERY
    end

    def build_transit_query(lat, lng, route_type, radius)
      bbox = calculate_bbox(lat, lng, radius)
      route_query = TRANSIT_ROUTE_QUERIES[route_type]

      <<~QUERY
        [out:json][timeout:30];
        (
          #{route_query}
        )(#{bbox});
        out body;
        >;
        out skel qt;
      QUERY
    end

    def calculate_bbox(lat, lng, radius)
      # Approximate degrees per meter at the equator
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

      return nil unless response.success?

      JSON.parse(response.body)
    rescue StandardError => e
      Rails.logger.error("Overpass API error: #{e.message}")
      nil
    end

    def parse_poi_response(response, origin_lat, origin_lng)
      return [] unless response && response['elements']

      response['elements'].map do |element|
        next unless element['lat'] && element['lon']

        {
          name: element.dig('tags', 'name'),
          latitude: element['lat'],
          longitude: element['lon'],
          osm_id: "#{element['type']}/#{element['id']}",
          address: build_address(element['tags']),
          opening_hours: element.dig('tags', 'opening_hours'),
          distance_meters: calculate_distance(
            origin_lat, origin_lng,
            element['lat'], element['lon']
          )
        }
      end.compact
    end

    def parse_transit_response(response)
      return [] unless response && response['elements']

      # Separate nodes and relations
      nodes = {}
      relations = []

      response['elements'].each do |element|
        case element['type']
        when 'node'
          nodes[element['id']] = [element['lat'], element['lon']]
        when 'relation'
          relations << element
        end
      end

      # Build route geometries from relations
      relations.map do |relation|
        members = relation['members'] || []
        way_nodes = members.select { |m| m['type'] == 'node' && m['role'] != 'stop' }

        geometry = way_nodes.map do |member|
          nodes[member['ref']]
        end.compact

        # If no direct node references, try to build from ways
        if geometry.empty?
          geometry = extract_geometry_from_ways(relation, nodes)
        end

        next if geometry.empty?

        {
          name: relation.dig('tags', 'name') || relation.dig('tags', 'ref'),
          osm_id: "relation/#{relation['id']}",
          color: relation.dig('tags', 'colour') || relation.dig('tags', 'color'),
          geometry: geometry
        }
      end.compact
    end

    def extract_geometry_from_ways(relation, nodes)
      # For relations that reference ways, we need the way geometry
      # This is a simplified approach - full implementation would need to fetch ways
      []
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
      # Haversine formula for distance in meters
      r = 6_371_000 # Earth's radius in meters

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
