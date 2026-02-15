class UnsplashService
  BASE_URL = "https://api.unsplash.com"

  class << self
    def fetch_images(city:, country: nil, limit: 20)
      query = build_search_query(city, country)
      search_photos(query: query, limit: limit)
    end

    private

    def search_photos(query:, limit:)
      params = {
        query: query,
        per_page: limit,
        orientation: "landscape", # Better for travel/destination photos
        content_filter: "high"    # Safe content only
      }

      response = make_request("/search/photos", params)
      return [] unless response && response["results"]

      response["results"].map do |photo|
        {
          "url" => photo.dig("urls", "full"),
          "thumb_url" => photo.dig("urls", "regular"), # 1080px wide
          "small_url" => photo.dig("urls", "small"),   # 400px wide
          "title" => photo["description"] || photo["alt_description"],
          "attribution" => build_attribution(photo),
          "photographer" => photo.dig("user", "name"),
          "photographer_url" => photo.dig("user", "links", "html"),
          "unsplash_url" => photo["links"]["html"],
          "width" => photo["width"],
          "height" => photo["height"],
          "color" => photo["color"], # Dominant color for placeholder
          "source" => "unsplash"
        }
      end
    end

    def build_search_query(city, country)
      # Search for travel-worthy photos of the destination
      parts = [ city ]
      parts << country if country.present?
      parts.join(" ")
    end

    def build_attribution(photo)
      photographer = photo.dig("user", "name") || "Unknown"
      "Photo by #{photographer} on Unsplash"
    end

    def make_request(endpoint, params = {})
      access_key = Rails.application.credentials.unsplash_access_key

      unless access_key.present?
        Rails.logger.error("Unsplash API key not configured")
        return nil
      end

      response = HTTParty.get(
        "#{BASE_URL}#{endpoint}",
        query: params,
        headers: {
          "Authorization" => "Client-ID #{access_key}",
          "Accept-Version" => "v1"
        },
        timeout: 15
      )

      unless response.success?
        Rails.logger.error("Unsplash API returned #{response.code}: #{response.body[0..200]}")
        return nil
      end

      JSON.parse(response.body)
    rescue StandardError => e
      Rails.logger.error("Unsplash API error: #{e.message}")
      nil
    end
  end
end
