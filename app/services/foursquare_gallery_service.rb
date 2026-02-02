class FoursquareGalleryService
  BASE_URL = 'https://places-api.foursquare.com'.freeze
  API_VERSION = '2025-02-05'.freeze

  # Foursquare category IDs for visually interesting, visit-worthy places
  CATEGORIES = [
    '16000', # Landmarks and Outdoors
    '10000', # Arts and Entertainment
    '13000', # Dining and Drinking
    '17000'  # Retail (iconic shops)
  ].freeze

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

    private

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
          fields: 'fsq_place_id,name,location,categories,photos,rating,price'
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
        'lat' => venue.dig('location', 'latitude'),
        'lng' => venue.dig('location', 'longitude'),
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
