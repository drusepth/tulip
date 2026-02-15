class FoursquareService
  BASE_URL = "https://places-api.foursquare.com".freeze
  API_VERSION = "2025-06-17".freeze
  SEARCH_RADIUS = 50 # meters
  MATCH_THRESHOLD = 0.6 # 60% similarity required for a match

  class << self
    # Enrich a Place with Foursquare data
    def enrich_place(place)
      return if place.foursquare_fetched_at.present?
      return unless api_key_configured?

      matching_place = find_matching_place(place)
      return mark_as_fetched(place) unless matching_place

      place.update(
        foursquare_id: matching_place["fsq_place_id"],
        foursquare_rating: matching_place["rating"],
        foursquare_price: matching_place["price"],
        foursquare_photo_url: extract_photo_url(matching_place),
        foursquare_tip: extract_top_tip(matching_place),
        foursquare_fetched_at: Time.current
      )
    end

    # Legacy: enrich via a POI (delegates to its place)
    def enrich_poi(poi)
      enrich_place(poi.place)
    end

    private

    def api_key_configured?
      api_key.present?
    end

    def api_key
      Rails.application.credentials.foursquare_service_token ||
        Rails.application.credentials.foursquare_api_key
    end

    def find_matching_place(place)
      response = HTTParty.get(
        "#{BASE_URL}/places/search",
        headers: {
          "Authorization" => "Bearer #{api_key}",
          "X-Places-Api-Version" => API_VERSION
        },
        query: {
          ll: "#{place.latitude},#{place.longitude}",
          radius: SEARCH_RADIUS,
          limit: 1,
          fields: "fsq_place_id,name,rating,price,photos,tips"
        },
        timeout: 10
      )

      unless response.success?
        Rails.logger.error("Foursquare API error: #{response.code} - #{response.body[0..200]}")
        return nil
      end

      places = response.parsed_response["results"]
      return nil if places.blank?

      best_match(place.name, places)
    rescue StandardError => e
      Rails.logger.error("Foursquare API exception: #{e.message}")
      nil
    end

    def best_match(poi_name, places)
      return nil if poi_name.blank? || places.blank?

      poi_name_normalized = poi_name.downcase.strip

      matches = places.map do |place|
        place_name = place["name"]&.downcase&.strip || ""
        score = similarity(poi_name_normalized, place_name)
        { place: place, score: score }
      end

      best = matches.max_by { |m| m[:score] }
      return nil unless best && best[:score] >= MATCH_THRESHOLD

      best[:place]
    end

    def similarity(a, b)
      return 1.0 if a == b
      return 0.0 if a.empty? || b.empty?

      longer = [ a.length, b.length ].max
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

    def extract_photo_url(place)
      photos = place["photos"]
      return nil if photos.blank?

      photo = photos.first
      return nil unless photo

      prefix = photo["prefix"]
      suffix = photo["suffix"]
      return nil unless prefix && suffix

      "#{prefix}300x200#{suffix}"
    end

    def extract_top_tip(place)
      tips = place["tips"]
      return nil if tips.blank?

      tip = tips.first
      tip&.dig("text")
    end

    def mark_as_fetched(place)
      place.update(foursquare_fetched_at: Time.current)
    end
  end
end
