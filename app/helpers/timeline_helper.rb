module TimelineHelper
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

    <<~HTML.html_safe
      <div class="timeline-tooltip">
        <div class="font-semibold text-brown">#{h(stay.title)}</div>
        <div class="text-sm text-brown-light">#{h(location)}</div>
        <div class="text-xs text-taupe mt-1">
          #{stay.check_in.strftime('%b %d')} &rarr; #{stay.check_out.strftime('%b %d, %Y')}
        </div>
        <div class="flex items-center gap-2 mt-2">
          #{status_badge}
          <span class="text-xs text-brown-light">#{stay.duration_days} nights</span>
        </div>
      </div>
    HTML
  end

  def gap_tooltip_content(gap)
    <<~HTML.html_safe
      <div class="timeline-tooltip">
        <div class="font-semibold text-coral-dark">#{gap[:days]} day gap</div>
        <div class="text-xs text-taupe mt-1">
          #{gap[:start_date].strftime('%b %d')} &rarr; #{gap[:end_date].strftime('%b %d, %Y')}
        </div>
        <div class="text-xs text-brown-light mt-2">Click to add a stay</div>
      </div>
    HTML
  end
end
