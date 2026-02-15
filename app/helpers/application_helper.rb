module ApplicationHelper
  CATEGORY_EMOJIS = {
    "coffee" => "☕",
    "food" => "🍝",
    "grocery" => "🛒",
    "gym" => "💪",
    "coworking" => "💻",
    "library" => "📚",
    "parks" => "🌳",
    "bus_stops" => "🚌",
    "stations" => "🚉"
  }.freeze

  def category_emoji(category)
    CATEGORY_EMOJIS[category] || "📍"
  end

  def format_distance(meters)
    miles = meters / 1609.34
    if miles < 0.1
      "#{(miles * 5280).round} ft"
    else
      "#{miles.round(1)} mi"
    end
  end

  # Polymorphic comment path helpers
  def commentable_comments_path(commentable)
    if commentable.is_a?(Place)
      place_comments_path(commentable)
    else
      stay_comments_path(commentable)
    end
  end

  def commentable_comment_path(commentable, comment)
    if commentable.is_a?(Place)
      place_comment_path(commentable, comment)
    else
      stay_comment_path(commentable, comment)
    end
  end

  def edit_commentable_comment_path(commentable, comment)
    if commentable.is_a?(Place)
      edit_place_comment_path(commentable, comment)
    else
      edit_stay_comment_path(commentable, comment)
    end
  end

  # Returns the place_search URL for mention autocomplete, or nil if not supported
  def mention_search_url(commentable)
    if commentable.is_a?(Stay)
      place_search_stay_path(commentable)
    elsif commentable.is_a?(Place)
      place_search_place_path(commentable)
    end
  end

  # Render @[Place Name](place:123) mentions as links
  def render_comment_body(body)
    return "" if body.blank?
    escaped = ERB::Util.html_escape(body)
    escaped.gsub(/@\[([^\]]+)\]\(place:(\d+)\)/) do
      name = Regexp.last_match(1)
      place_id = Regexp.last_match(2)
      "<a href=\"#{place_path(place_id)}\" class=\"place-mention\">@#{name}</a>"
    end.html_safe
  end

  def commentable_path(commentable)
    if commentable.is_a?(Place)
      place_path(commentable)
    else
      stay_path(commentable)
    end
  end
end
