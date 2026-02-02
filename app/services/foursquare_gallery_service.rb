class FoursquareGalleryService
  BASE_URL = 'https://places-api.foursquare.com'.freeze
  API_VERSION = '2025-06-17'.freeze
  MATCH_RADIUS = 100 # meters for matching existing POIs
  MATCH_THRESHOLD = 0.6 # 60% similarity required for a match

  # Foursquare category IDs for visually interesting, visit-worthy places
  CATEGORIES = [
    '16000', # Landmarks and Outdoors
    '10000', # Arts and Entertainment
    '13000', # Dining and Drinking
    '17000'  # Retail (iconic shops)
  ].freeze

  # Map Foursquare category names to our POI categories
  CATEGORY_MAPPING = {
    /restaurant|cafe|coffee|bakery|bar|pub|brewery|winery|food|dining|pizza|sushi|taco|burger/i => 'food',
    /coffee|tea|espresso/i => 'coffee',
    /gym|fitness|sport|yoga/i => 'gym',
    /library|bookstore/i => 'library',
    /park|garden|beach|trail|nature|lake|mountain|forest/i => 'parks',
    /grocery|supermarket|market/i => 'grocery',
    /coworking|office/i => 'coworking',
    /station|metro|subway|train|bus/i => 'stations'
  }.freeze

  class << self
    def fetch_venues_with_photos(lat:, lng:, radius: 5000, limit: 20)
      return [] unless api_key_configured?

      venues = search_venues(lat: lat, lng: lng, radius: radius, limit: limit * 2)
      return [] if venues.blank?

      # Filter to only venues that have photos and a name, then map to our format
      venues_with_photos = venues.select { |v| v['name'].present? && v['photos'].present? && v['photos'].any? }
      venues_with_photos.first(limit).map { |venue| format_venue(venue) }
    rescue StandardError => e
      Rails.logger.error("FoursquareGalleryService error: #{e.message}")
      []
    end

    def fetch_and_save_pois(stay:, radius: 5000, limit: 20)
      return [] unless api_key_configured?
      return [] unless stay.latitude.present? && stay.longitude.present?

      venues = search_venues(lat: stay.latitude, lng: stay.longitude, radius: radius, limit: limit * 2)
      return [] if venues.blank?

      venues_with_photos = venues.select { |v| v['name'].present? && v['photos'].present? && v['photos'].any? }
      return [] if venues_with_photos.empty?

      # Batch load existing data upfront (2 queries instead of N*2)
      existing_fsq_ids = stay.pois.where.not(foursquare_id: nil).pluck(:foursquare_id).to_set
      matchable_pois = stay.pois.where(foursquare_id: nil).to_a

      # Process venues and collect actions
      new_records = []
      enrichments = []

      venues_with_photos.first(limit).each do |venue|
        result = process_venue(
          stay: stay,
          venue: venue,
          existing_fsq_ids: existing_fsq_ids,
          matchable_pois: matchable_pois
        )

        next unless result

        case result[:action]
        when :create
          new_records << result[:attributes]
          # Add to existing set to prevent duplicates within the same batch
          existing_fsq_ids.add(result[:attributes][:foursquare_id])
        when :enrich
          enrichments << result
        end
      end

      # Bulk insert new POIs (1 query instead of N inserts with transactions)
      if new_records.any?
        Poi.insert_all(new_records)
      end

      # Batch update enrichments
      enrichments.each do |e|
        e[:poi].update_columns(e[:attributes])
      end

      stay.pois.where.not(foursquare_photo_url: [nil, '']).or(stay.pois.where.not(foursquare_id: nil))
    rescue StandardError => e
      Rails.logger.error("FoursquareGalleryService fetch_and_save_pois error: #{e.message}")
      []
    end

    private

    def process_venue(stay:, venue:, existing_fsq_ids:, matchable_pois:)
      venue_lat = venue['latitude']
      venue_lng = venue['longitude']
      venue_name = venue['name']
      fsq_id = venue['fsq_place_id']

      return nil unless venue_lat && venue_lng && venue_name && fsq_id

      # Skip if we already have this Foursquare ID (checked in memory)
      return nil if existing_fsq_ids.include?(fsq_id)

      # Find matching POI in memory instead of querying database
      matching_poi = find_matching_poi_in_memory(
        venue_name: venue_name,
        venue_lat: venue_lat,
        venue_lng: venue_lng,
        matchable_pois: matchable_pois
      )

      if matching_poi
        { action: :enrich, poi: matching_poi, attributes: build_enrichment_attributes(venue) }
      else
        { action: :create, attributes: build_create_attributes(stay, venue) }
      end
    end

    def find_matching_poi_in_memory(venue_name:, venue_lat:, venue_lng:, matchable_pois:)
      lat_delta = MATCH_RADIUS / 111_000.0
      lng_delta = MATCH_RADIUS / (111_000.0 * Math.cos(venue_lat * Math::PI / 180))

      venue_name_normalized = venue_name.downcase.strip

      matchable_pois.find do |poi|
        next false unless poi.latitude && poi.longitude
        next false unless (poi.latitude.to_f - venue_lat).abs <= lat_delta
        next false unless (poi.longitude.to_f - venue_lng).abs <= lng_delta
        next false if poi.name.blank?

        similarity(venue_name_normalized, poi.name.downcase.strip) >= MATCH_THRESHOLD
      end
    end

    def build_enrichment_attributes(venue)
      photo = venue['photos']&.first
      {
        foursquare_id: venue['fsq_place_id'],
        foursquare_rating: venue['rating'],
        foursquare_price: venue['price'],
        foursquare_photo_url: build_photo_url(photo, '600x400'),
        foursquare_fetched_at: Time.current
      }
    end

    def build_create_attributes(stay, venue)
      photo = venue['photos']&.first
      category = venue.dig('categories', 0)
      venue_lat = venue['latitude']
      venue_lng = venue['longitude']
      distance = haversine_distance(stay.latitude, stay.longitude, venue_lat, venue_lng)
      now = Time.current

      {
        stay_id: stay.id,
        name: venue['name'],
        category: map_foursquare_to_poi_category(category&.dig('name')),
        latitude: venue_lat,
        longitude: venue_lng,
        address: venue.dig('location', 'formatted_address'),
        distance_meters: distance.round,
        source: 'foursquare',
        foursquare_id: venue['fsq_place_id'],
        foursquare_rating: venue['rating'],
        foursquare_price: venue['price'],
        foursquare_photo_url: build_photo_url(photo, '600x400'),
        foursquare_fetched_at: now,
        created_at: now,
        updated_at: now,
        favorite: false
      }
    end

    def map_foursquare_to_poi_category(foursquare_category_name)
      return 'food' if foursquare_category_name.blank?

      CATEGORY_MAPPING.each do |pattern, poi_category|
        return poi_category if foursquare_category_name.match?(pattern)
      end

      'food' # Default to food for gallery venues
    end

    def haversine_distance(lat1, lng1, lat2, lng2)
      # Returns distance in meters
      r = 6371000 # Earth's radius in meters

      lat1_rad = lat1 * Math::PI / 180
      lat2_rad = lat2 * Math::PI / 180
      delta_lat = (lat2 - lat1) * Math::PI / 180
      delta_lng = (lng2 - lng1) * Math::PI / 180

      a = Math.sin(delta_lat / 2)**2 +
          Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(delta_lng / 2)**2
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

      r * c
    end

    def similarity(a, b)
      return 1.0 if a == b
      return 0.0 if a.empty? || b.empty?

      longer = [a.length, b.length].max
      distance = levenshtein_distance(a, b)
      (longer - distance) / longer.to_f
    end

    def levenshtein_distance(s1, s2)
      m = s1.length
      n = s2.length

      return n if m.zero?
      return m if n.zero?

      d = Array.new(m + 1) { Array.new(n + 1, 0) }

      (0..m).each { |i| d[i][0] = i }
      (0..n).each { |j| d[0][j] = j }

      (1..m).each do |i|
        (1..n).each do |j|
          cost = s1[i - 1] == s2[j - 1] ? 0 : 1
          d[i][j] = [
            d[i - 1][j] + 1,      # deletion
            d[i][j - 1] + 1,      # insertion
            d[i - 1][j - 1] + cost # substitution
          ].min
        end
      end

      d[m][n]
    end

    def api_key_configured?
      api_key.present?
    end

    def api_key
      Rails.application.credentials.foursquare_service_token ||
        Rails.application.credentials.foursquare_api_key
    end

    def search_venues(lat:, lng:, radius:, limit:)
      response = HTTParty.get(
        "#{BASE_URL}/places/search",
        headers: {
          'Authorization' => "Bearer #{api_key}",
          'X-Places-Api-Version' => API_VERSION
        },
        query: {
          ll: "#{lat},#{lng}",
          radius: radius,
          categories: CATEGORIES.join(','),
          limit: limit,
          fields: 'fsq_place_id,name,latitude,longitude,location,categories,photos,rating,price'
        },
        timeout: 15
      )

      unless response.success?
        Rails.logger.error("Foursquare API error: #{response.code} - #{response.body[0..200]}")
        return []
      end

      response.parsed_response['results'] || []
    end

    def format_venue(venue)
      photo = venue['photos'].first
      category = venue.dig('categories', 0)

      {
        'fsq_id' => venue['fsq_place_id'],
        'name' => venue['name'],
        'address' => venue.dig('location', 'formatted_address'),
        'category' => category&.dig('name') || 'Place',
        'category_icon' => build_category_icon_url(category),
        'photo_url' => build_photo_url(photo, '600x400'),
        'thumb_url' => build_photo_url(photo, '300x300'),
        'lat' => venue['latitude'],
        'lng' => venue['longitude'],
        'rating' => venue['rating'],
        'price' => venue['price'],
        'source' => 'foursquare'
      }
    end

    def build_photo_url(photo, size)
      return nil unless photo
      prefix = photo['prefix']
      suffix = photo['suffix']
      return nil unless prefix && suffix
      "#{prefix}#{size}#{suffix}"
    end

    def build_category_icon_url(category)
      return nil unless category
      prefix = category.dig('icon', 'prefix')
      suffix = category.dig('icon', 'suffix')
      return nil unless prefix && suffix
      "#{prefix}64#{suffix}"
    end
  end
end
