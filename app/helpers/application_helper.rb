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

  # Render @[Name](place:123) and @[Name](user:123) mentions as styled inline elements.
  # Works for any text field (comments, bucket list items, etc.)
  def render_text_with_mentions(body)
    return "" if body.blank?
    escaped = ERB::Util.html_escape(body)
    escaped.gsub(/@\[([^\]]+)\]\((place|user):(\d+)\)/) do
      name = Regexp.last_match(1)
      mention_type = Regexp.last_match(2)
      mention_id = Regexp.last_match(3)
      if mention_type == "user"
        "<span class=\"user-mention\">@#{name}</span>"
      else
        "<a href=\"#{place_path(mention_id)}\" class=\"place-mention\">@#{name}</a>"
      end
    end.html_safe
  end

  # Extract mentioned user IDs from text containing @[Name](user:123) patterns.
  # Only returns IDs for users who are actual collaborators on the given stay.
  def self.extract_mentioned_user_ids(text, stay:)
    return [] if text.blank? || stay.nil?
    user_ids = text.scan(/@\[[^\]]+\]\(user:(\d+)\)/).flatten.map(&:to_i)
    return [] if user_ids.empty?

    # Only include users who are part of this stay (owner + accepted collaborators)
    valid_user_ids = [ stay.user_id ] + stay.collaborators.pluck(:id)
    user_ids & valid_user_ids
  end

  alias_method :render_comment_body, :render_text_with_mentions

  def commentable_path(commentable)
    if commentable.is_a?(Place)
      place_path(commentable)
    else
      stay_path(commentable)
    end
  end
end
