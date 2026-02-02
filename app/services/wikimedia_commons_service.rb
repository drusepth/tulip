class WikimediaCommonsService
  BASE_URL = "https://commons.wikimedia.org/w/api.php"

  class << self
    def fetch_images(lat:, lng:, radius: 10000, limit: 20)
      # Step 1: Geosearch for files near coordinates
      page_ids = geosearch(lat: lat, lng: lng, radius: radius, limit: limit)
      return [] if page_ids.empty?

      # Step 2: Get image info (URLs, dimensions, attribution)
      fetch_image_info(page_ids)
    end

    private

    def geosearch(lat:, lng:, radius:, limit:)
      params = {
        action: "query",
        list: "geosearch",
        gscoord: "#{lat}|#{lng}",
        gsradius: radius,
        gsnamespace: 6, # File namespace
        gslimit: limit,
        format: "json"
      }

      response = make_request(params)
      return [] unless response && response.dig("query", "geosearch")

      response["query"]["geosearch"].map { |item| item["pageid"] }
    end

    def fetch_image_info(page_ids)
      params = {
        action: "query",
        pageids: page_ids.join("|"),
        prop: "imageinfo",
        iiprop: "url|extmetadata|size",
        iiurlwidth: 800, # Request thumbnail at 800px width
        format: "json"
      }

      response = make_request(params)
      return [] unless response && response.dig("query", "pages")

      response["query"]["pages"].values.filter_map do |page|
        next unless page["imageinfo"]&.any?

        info = page["imageinfo"].first
        metadata = info["extmetadata"] || {}

        # Skip non-image files (videos, PDFs, etc.)
        next unless image_file?(page["title"])

        {
          "url" => info["url"],
          "thumb_url" => info["thumburl"] || info["url"],
          "title" => page["title"],
          "attribution" => build_attribution(metadata),
          "width" => info["width"],
          "height" => info["height"],
          "source" => "wikimedia"
        }
      end
    end

    def image_file?(title)
      return false unless title

      title.match?(/\.(jpg|jpeg|png|gif|webp|svg)$/i)
    end

    def build_attribution(metadata)
      artist = extract_text(metadata.dig("Artist", "value"))
      license = extract_text(metadata.dig("LicenseShortName", "value"))

      parts = []
      parts << "Photo by #{artist}" if artist.present?
      parts << license if license.present?

      parts.any? ? parts.join(", ") : "Wikimedia Commons"
    end

    def extract_text(html_or_text)
      return nil unless html_or_text

      # Strip HTML tags if present
      ActionController::Base.helpers.strip_tags(html_or_text).strip.presence
    end

    def make_request(params)
      response = HTTParty.get(
        BASE_URL,
        query: params,
        headers: {
          "User-Agent" => "Tulip Travel App (https://github.com/drusepth/tulip)"
        },
        timeout: 15
      )

      unless response.success?
        Rails.logger.error("Wikimedia API returned #{response.code}: #{response.body[0..200]}")
        return nil
      end

      JSON.parse(response.body)
    rescue StandardError => e
      Rails.logger.error("Wikimedia API error: #{e.message}")
      nil
    end
  end
end
