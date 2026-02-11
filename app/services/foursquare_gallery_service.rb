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

      # Batch load existing data upfront
      existing_fsq_ids = Place.where.not(foursquare_id: nil)
                              .where(foursquare_id: venues_with_photos.map { |v| v['fsq_place_id'] }.compact)
                              .pluck(:foursquare_id).to_set
      existing_place_pois = stay.pois.includes(:place).to_a

      venues_with_photos.first(limit).each do |venue|
        fsq_id = venue['fsq_place_id']
        next unless fsq_id && venue['name'] && venue['latitude'] && venue['longitude']

        # Find or create the Place
        place = Place.find_by(foursquare_id: fsq_id)
        unless place
          # Try to match by name + proximity to an existing place
          place = find_nearby_place(venue)
        end

        if place
          # Enrich existing place with Foursquare data if not already done
          unless place.foursquare_fetched_at.present?
            photo = venue['photos']&.first
            place.update(
              foursquare_id: fsq_id,
              foursquare_rating: venue['rating'],
              foursquare_price: venue['price'],
              foursquare_photo_url: build_photo_url(photo, '600x400'),
              foursquare_fetched_at: Time.current
            )
          end
        else
          # Create a new Place from Foursquare data
          photo = venue['photos']&.first
          category_name = venue.dig('categories', 0, 'name')
          place = Place.create(
            name: venue['name'],
            category: map_foursquare_to_poi_category(category_name),
            latitude: venue['latitude'],
            longitude: venue['longitude'],
            address: venue.dig('location', 'formatted_address'),
            source: 'foursquare',
            foursquare_id: fsq_id,
            foursquare_rating: venue['rating'],
            foursquare_price: venue['price'],
            foursquare_photo_url: build_photo_url(photo, '600x400'),
            foursquare_fetched_at: Time.current
          )
        end

        # Create POI join if it doesn't exist
        unless existing_place_pois.any? { |p| p.place_id == place.id }
          distance = haversine_distance(stay.latitude, stay.longitude, place.latitude, place.longitude)
          stay.pois.create(
            place: place,
            category: place.category,
            distance_meters: distance.round,
            favorite: false
          )
        end
      end

      stay.pois.includes(:place).joins(:place)
          .where("places.foursquare_photo_url IS NOT NULL AND places.foursquare_photo_url != ''")
    rescue StandardError => e
      Rails.logger.error("FoursquareGalleryService fetch_and_save_pois error: #{e.message}")
      []
    end

    private

    def find_nearby_place(venue)
      venue_lat = venue['latitude']
      venue_lng = venue['longitude']
      venue_name = venue['name']

      return nil unless venue_lat && venue_lng && venue_name

      lat_delta = MATCH_RADIUS / 111_000.0
      lng_delta = MATCH_RADIUS / (111_000.0 * Math.cos(venue_lat * Math::PI / 180))

      candidates = Place.where(foursquare_id: nil)
                        .where(latitude: (venue_lat - lat_delta)..(venue_lat + lat_delta))
                        .where(longitude: (venue_lng - lng_delta)..(venue_lng + lng_delta))

      venue_name_normalized = venue_name.downcase.strip

      candidates.find do |place|
        next false if place.name.blank?
        similarity(venue_name_normalized, place.name.downcase.strip) >= MATCH_THRESHOLD
      end
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
