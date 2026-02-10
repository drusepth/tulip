module PoisHelper
  # Convert Foursquare 1-10 rating to 5-star display
  def foursquare_rating_stars(rating)
    return nil unless rating
    stars = (rating / 2.0).round(1)
    "#{stars}/5"
  end

  # Convert Foursquare 1-4 price to dollar signs
  def foursquare_price_display(price)
    return nil unless price
    '$' * price
  end

  # Check if POI has Foursquare enrichment data
  def poi_has_foursquare_data?(poi)
    poi.foursquare_rating.present? ||
      poi.foursquare_price.present? ||
      poi.foursquare_photo_url.present? ||
      poi.foursquare_tip.present?
  end

  # Parse OSM opening_hours format into readable display
  # Example input: "Mo-Fr 08:00-18:00; Sa 09:00-14:00"
  def format_opening_hours(hours_string)
    return nil if hours_string.blank?

    # Common abbreviation mappings
    day_map = {
      'Mo' => 'Mon', 'Tu' => 'Tue', 'We' => 'Wed', 'Th' => 'Thu',
      'Fr' => 'Fri', 'Sa' => 'Sat', 'Su' => 'Sun',
      'PH' => 'Holidays'
    }

    # Split by semicolon for multiple rules
    rules = hours_string.split(';').map(&:strip)

    rules.map do |rule|
      # Handle 24/7
      next '24/7' if rule == '24/7'

      # Replace day abbreviations
      formatted = rule.dup
      day_map.each { |short, long| formatted.gsub!(short, long) }

      # Replace hyphen ranges for days
      formatted.gsub!(/(\w+)-(\w+)/, '\1-\2')

      formatted
    end.compact
  end

  def format_phone(phone)
    return nil if phone.blank?
    # Return as-is, but ensure it's safe for display
    phone.strip
  end

  def format_website_domain(website)
    return nil if website.blank?
    begin
      uri = URI.parse(website)
      uri.host&.sub(/^www\./, '') || website
    rescue URI::InvalidURIError
      website
    end
  end

  def poi_has_wikidata_data?(poi)
    poi.wikipedia_extract.present? ||
      poi.wikipedia_url.present? ||
      poi.wikidata_image_url.present?
  end

  def poi_has_details?(poi)
    poi.address.present? ||
      poi.opening_hours.present? ||
      poi.phone.present? ||
      poi.website.present? ||
      poi.cuisine.present? ||
      poi.outdoor_seating? ||
      poi.internet_access.present? ||
      poi.air_conditioning? ||
      poi.takeaway? ||
      poi.brand.present? ||
      poi.description.present? ||
      poi_has_foursquare_data?(poi)
  end

  def poi_amenity_badges(poi)
    badges = []
    badges << { label: 'WiFi', icon: 'wifi' } if poi.internet_access.present? && poi.internet_access != 'no'
    badges << { label: 'Outdoor', icon: 'outdoor' } if poi.outdoor_seating?
    badges << { label: 'A/C', icon: 'ac' } if poi.air_conditioning?
    badges << { label: 'Takeaway', icon: 'takeaway' } if poi.takeaway?
    badges
  end

  def category_icon(category, size: nil)
    # The SVG class handles sizing - uses CSS class .category-pill svg for small context
    # or w-5 h-5 as default for larger contexts
    svg_class = size || "w-5 h-5"

    icon_path = case category
    when 'coffee'
      '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"></path>'
    when 'grocery'
      '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z"></path>'
    when 'food'
      '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"></path>'
    when 'gym'
      '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"></path>'
    when 'coworking'
      '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path>'
    when 'library'
      '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"></path>'
    else
      '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>'
    end

    %(<svg class="#{svg_class}" fill="none" stroke="currentColor" viewBox="0 0 24 24">#{icon_path}</svg>).html_safe
  end
end
