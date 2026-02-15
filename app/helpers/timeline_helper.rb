module TimelineHelper
  STAY_TYPE_ICONS = {
    "airbnb" => '<svg class="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-1.85 0-3.55-.63-4.9-1.69 1.08-1.04 2.33-1.8 3.7-2.22.47-.14.97-.22 1.5-.22s1.03.08 1.5.22c1.37.42 2.62 1.18 3.7 2.22C15.55 19.37 13.85 20 12 20zm0-4c-2.21 0-4-1.79-4-4s1.79-4 4-4 4 1.79 4 4-1.79 4-4 4z"/></svg>',
    "hotel" => '<svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/></svg>',
    "hostel" => '<svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/></svg>',
    "friend" => '<svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"/></svg>',
    "other" => '<svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/></svg>'
  }.freeze

  WEATHER_CONDITION_ICONS = {
    sunny: '<svg class="w-3 h-3 text-amber-500" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 2a1 1 0 011 1v1a1 1 0 11-2 0V3a1 1 0 011-1zm4 8a4 4 0 11-8 0 4 4 0 018 0zm-.464 4.95l.707.707a1 1 0 001.414-1.414l-.707-.707a1 1 0 00-1.414 1.414zm2.12-10.607a1 1 0 010 1.414l-.706.707a1 1 0 11-1.414-1.414l.707-.707a1 1 0 011.414 0zM17 11a1 1 0 100-2h-1a1 1 0 100 2h1zm-7 4a1 1 0 011 1v1a1 1 0 11-2 0v-1a1 1 0 011-1zM5.05 6.464A1 1 0 106.465 5.05l-.708-.707a1 1 0 00-1.414 1.414l.707.707zm1.414 8.486l-.707.707a1 1 0 01-1.414-1.414l.707-.707a1 1 0 011.414 1.414zM4 11a1 1 0 100-2H3a1 1 0 000 2h1z" clip-rule="evenodd"/></svg>',
    cloudy: '<svg class="w-3 h-3 text-slate-400" fill="currentColor" viewBox="0 0 20 20"><path d="M5.5 16a3.5 3.5 0 01-.369-6.98 4 4 0 117.753-1.977A4.5 4.5 0 1113.5 16h-8z"/></svg>',
    rainy: '<svg class="w-3 h-3 text-blue-400" fill="currentColor" viewBox="0 0 20 20"><path d="M5.5 13a3.5 3.5 0 01-.369-6.98 4 4 0 117.753-1.977A4.5 4.5 0 1113.5 13h-8z"/><path d="M7 14v3m4-4v4m-6-2v2" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg>',
    snowy: '<svg class="w-3 h-3 text-sky-300" fill="currentColor" viewBox="0 0 20 20"><path d="M10 2l1.5 3 3.5.5-2.5 2.5.5 3.5-3-1.5-3 1.5.5-3.5L5 6l3.5-.5L10 2z"/></svg>'
  }.freeze

  SEASON_ICONS = {
    spring: '<svg class="w-4 h-4 text-rose" viewBox="0 0 24 24" fill="currentColor"><path d="M12 22c1-3 3-5.5 3-8a3 3 0 10-6 0c0 2.5 2 5 3 8zm0-18c-1 3-3 5.5-3 8a3 3 0 106 0c0-2.5-2-5-3-8z"/><path d="M22 12c-3-1-5.5-3-8-3a3 3 0 100 6c2.5 0 5-2 8-3zM2 12c3 1 5.5 3 8 3a3 3 0 100-6c-2.5 0-5 2-8 3z"/></svg>',
    summer: '<svg class="w-4 h-4 text-amber-400" viewBox="0 0 24 24" fill="currentColor"><circle cx="12" cy="12" r="5"/><path d="M12 1v2m0 18v2M4.22 4.22l1.42 1.42m12.72 12.72l1.42 1.42M1 12h2m18 0h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/></svg>',
    fall: '<svg class="w-4 h-4 text-orange-500" viewBox="0 0 24 24" fill="currentColor"><path d="M17 8c-4 0-8 2-8 8 0 1 0 2 .5 3 .5-1 1.5-2 3.5-2s3 1 3.5 2c.5-1 .5-2 .5-3 0-6-4-8-8-8z"/><path d="M12 2c-2 4-2 6 0 8 2-2 2-4 0-8z"/></svg>',
    winter: '<svg class="w-4 h-4 text-sky-300" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2v20M2 12h20M4.93 4.93l14.14 14.14M19.07 4.93L4.93 19.07"/></svg>'
  }.freeze

  def tooltip_content_for(stay)
    status_badge = if stay.booked?
      badge_class = case stay.status
      when "upcoming" then "badge-upcoming"
      when "current" then "badge-current"
      when "past" then "badge-past"
      else "badge-upcoming"
      end
      "<span class='badge #{badge_class}'>#{stay.status.capitalize}</span>"
    else
      "<span class='badge badge-planned'>Planned</span>"
    end

    location = [ stay.city, stay.state, stay.country ].compact.reject(&:blank?).join(", ")

    # Weather info
    weather_html = ""
    if stay.weather_data.present?
      weather = stay.expected_weather
      if weather
        temp_range = "#{weather[:temp_min]&.round}&deg;-#{weather[:temp_max]&.round}&deg;F"
        condition = weather[:condition] || "mild"
        weather_html = <<~WEATHER
          <div class="flex items-center gap-1 text-xs text-brown-light mt-1">
            #{weather_icon_for(condition)}
            <span>#{temp_range}, #{condition}</span>
          </div>
        WEATHER
      end
    end

    # Price info
    price_html = ""
    if stay.price_total_cents.present? && stay.price_total_cents > 0
      price_html = <<~PRICE
        <div class="text-xs text-brown-light mt-1">
          #{stay.currency} #{format_price(stay.price_total_cents)} total
          <span class="opacity-70">(#{stay.currency} #{format_price(stay.price_total_cents / [ stay.duration_days, 1 ].max)}/night)</span>
        </div>
      PRICE
    end

    # Bucket list info
    bucket_html = ""
    bucket_count = stay.bucket_list_items.size
    if bucket_count > 0
      completed = stay.bucket_list_items.count(&:completed?)
      bucket_html = <<~BUCKET
        <div class="text-xs text-brown-light mt-1">
          #{bucket_count} bucket list items (#{completed} done)
        </div>
      BUCKET
    end

    # Notes preview
    notes_html = ""
    if stay.notes.present?
      truncated = stay.notes.truncate(80)
      notes_html = <<~NOTES
        <div class="text-xs text-taupe mt-2 italic border-l-2 border-taupe-light pl-2">
          "#{h(truncated)}"
        </div>
      NOTES
    end

    # Stay type
    type_label = stay.stay_type.present? ? stay.stay_type.titleize : nil

    <<~HTML.html_safe
      <div class="timeline-tooltip">
        <div class="flex items-center gap-2">
          <div class="font-semibold text-brown">#{h(stay.title)}</div>
          #{type_label ? "<span class='text-xs text-taupe'>(#{type_label})</span>" : ""}
        </div>
        <div class="text-sm text-brown-light">#{h(location)}</div>
        <div class="text-xs text-taupe mt-1">
          #{stay.check_in.strftime('%b %d')} &rarr; #{stay.check_out.strftime('%b %d, %Y')}
        </div>
        <div class="flex items-center gap-2 mt-2">
          #{status_badge}
          <span class="text-xs text-brown-light">#{stay.duration_days} nights</span>
        </div>
        #{weather_html}
        #{price_html}
        #{bucket_html}
        #{notes_html}
      </div>
    HTML
  end

  def gap_tooltip_content(gap)
    weeks = (gap[:days] / 7.0).round(1)
    weeks_text = weeks >= 1 ? " (~#{weeks} weeks)" : ""

    <<~HTML.html_safe
      <div class="timeline-tooltip">
        <div class="font-semibold text-coral-dark">#{gap[:days]} day gap#{weeks_text}</div>
        <div class="text-xs text-taupe mt-1">
          #{gap[:start_date].strftime('%b %d')} &rarr; #{gap[:end_date].strftime('%b %d, %Y')}
        </div>
        <div class="flex items-center gap-1 text-xs text-brown-light mt-2">
          <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
          </svg>
          Click to add a stay
        </div>
      </div>
    HTML
  end

  def stay_type_icon(stay_type)
    STAY_TYPE_ICONS[stay_type] || STAY_TYPE_ICONS["other"]
  end

  def weather_icon_for(condition)
    case condition.to_s.downcase
    when /sun|clear|fair/
      WEATHER_CONDITION_ICONS[:sunny]
    when /cloud|overcast/
      WEATHER_CONDITION_ICONS[:cloudy]
    when /rain|shower|drizzle/
      WEATHER_CONDITION_ICONS[:rainy]
    when /snow|ice|frost/
      WEATHER_CONDITION_ICONS[:snowy]
    else
      WEATHER_CONDITION_ICONS[:cloudy]
    end
  end

  def season_icon(season)
    SEASON_ICONS[season.to_sym] || ""
  end

  def format_price(cents)
    return "0" if cents.nil? || cents == 0
    number_with_delimiter((cents / 100.0).round(2))
  end

  def format_currency(cents, currency = "USD")
    return "-" if cents.nil? || cents == 0
    "#{currency} #{format_price(cents)}"
  end

  def stat_icon(type)
    case type
    when :nights
      '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"/></svg>'
    when :gaps
      '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>'
    when :countries
      '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>'
    when :cities
      '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/></svg>'
    when :cost
      '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>'
    when :avg_stay
      '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/></svg>'
    else
      '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>'
    end
  end
end
