class WikidataService
  WIKIDATA_API = 'https://www.wikidata.org/w/api.php'.freeze
  WIKIPEDIA_API = 'https://en.wikipedia.org/w/api.php'.freeze
  SEARCH_RADIUS_KM = 1 # Max distance for coordinate-based matching

  class << self
    def enrich_poi(poi)
      return if poi.wikidata_fetched_at.present?

      # Step 1: Resolve wikidata ID (from OSM tag or by searching)
      wikidata_id = poi.wikidata_id.presence || search_wikidata_id(poi)

      unless wikidata_id
        return mark_as_fetched(poi)
      end

      # Step 2: Fetch entity data from Wikidata
      entity = fetch_entity(wikidata_id)
      unless entity
        return mark_as_fetched(poi, wikidata_id: wikidata_id)
      end

      # Step 3: Extract Wikipedia title and fetch extract
      wikipedia_title = entity.dig('sitelinks', 'enwiki', 'title')
      wikipedia_extract = fetch_wikipedia_extract(wikipedia_title) if wikipedia_title
      wikipedia_url = build_wikipedia_url(wikipedia_title) if wikipedia_title

      # Step 4: Extract Wikimedia Commons image
      image_url = extract_commons_image_url(entity)

      poi.update(
        wikidata_id: wikidata_id,
        wikipedia_url: wikipedia_url,
        wikipedia_extract: wikipedia_extract,
        wikidata_image_url: image_url,
        wikidata_fetched_at: Time.current
      )
    rescue StandardError => e
      Rails.logger.error("WikidataService error for POI #{poi.id}: #{e.message}")
      mark_as_fetched(poi)
    end

    private

    # Search Wikidata for an entity matching this POI by name + coordinates
    def search_wikidata_id(poi)
      return nil unless poi.name.present? && poi.latitude.present? && poi.longitude.present?

      response = HTTParty.get(WIKIDATA_API, query: {
        action: 'wbsearchentities',
        search: poi.name,
        language: 'en',
        format: 'json',
        limit: 5
      }, timeout: 10)

      return nil unless response.success?

      results = response.parsed_response['search']
      return nil if results.blank?

      # Check each candidate for coordinate proximity
      results.each do |result|
        entity = fetch_entity(result['id'])
        next unless entity

        coords = extract_coordinates(entity)
        next unless coords

        distance = haversine_km(
          poi.latitude.to_f, poi.longitude.to_f,
          coords[:lat], coords[:lng]
        )

        return result['id'] if distance <= SEARCH_RADIUS_KM
      end

      nil
    rescue StandardError => e
      Rails.logger.error("WikidataService search error: #{e.message}")
      nil
    end

    def fetch_entity(wikidata_id)
      response = HTTParty.get(WIKIDATA_API, query: {
        action: 'wbgetentities',
        ids: wikidata_id,
        format: 'json',
        props: 'claims|sitelinks|descriptions',
        languages: 'en'
      }, timeout: 10)

      return nil unless response.success?

      response.parsed_response.dig('entities', wikidata_id)
    rescue StandardError => e
      Rails.logger.error("WikidataService fetch_entity error: #{e.message}")
      nil
    end

    def fetch_wikipedia_extract(title)
      response = HTTParty.get(WIKIPEDIA_API, query: {
        action: 'query',
        prop: 'extracts',
        exintro: 1,
        explaintext: 1,
        exsentences: 3,
        titles: title,
        format: 'json'
      }, timeout: 10)

      return nil unless response.success?

      pages = response.parsed_response.dig('query', 'pages')
      return nil unless pages

      page = pages.values.first
      extract = page&.dig('extract')
      extract.presence
    rescue StandardError => e
      Rails.logger.error("WikidataService Wikipedia extract error: #{e.message}")
      nil
    end

    def extract_coordinates(entity)
      coord_claim = entity.dig('claims', 'P625')&.first
      return nil unless coord_claim

      value = coord_claim.dig('mainsnak', 'datavalue', 'value')
      return nil unless value && value['latitude'] && value['longitude']

      { lat: value['latitude'].to_f, lng: value['longitude'].to_f }
    end

    def extract_commons_image_url(entity)
      image_claim = entity.dig('claims', 'P18')&.first
      return nil unless image_claim

      filename = image_claim.dig('mainsnak', 'datavalue', 'value')
      return nil if filename.blank?

      commons_thumb_url(filename)
    end

    # Build a Wikimedia Commons thumbnail URL from a filename
    # Uses the standard MD5-based path structure
    def commons_thumb_url(filename)
      encoded_name = filename.tr(' ', '_')
      md5 = Digest::MD5.hexdigest(encoded_name)
      escaped = CGI.escape(encoded_name)

      "https://upload.wikimedia.org/wikipedia/commons/thumb/#{md5[0]}/#{md5[0..1]}/#{escaped}/400px-#{escaped}"
    end

    def build_wikipedia_url(title)
      "https://en.wikipedia.org/wiki/#{CGI.escape(title.tr(' ', '_'))}"
    end

    def haversine_km(lat1, lng1, lat2, lng2)
      r = 6371.0 # Earth radius in km

      phi1 = lat1 * Math::PI / 180
      phi2 = lat2 * Math::PI / 180
      delta_phi = (lat2 - lat1) * Math::PI / 180
      delta_lambda = (lng2 - lng1) * Math::PI / 180

      a = Math.sin(delta_phi / 2)**2 +
          Math.cos(phi1) * Math.cos(phi2) * Math.sin(delta_lambda / 2)**2
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

      r * c
    end

    def mark_as_fetched(poi, wikidata_id: nil)
      attrs = { wikidata_fetched_at: Time.current }
      attrs[:wikidata_id] = wikidata_id if wikidata_id
      poi.update(attrs)
    end
  end
end
