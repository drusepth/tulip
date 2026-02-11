module ApplicationHelper
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

  def commentable_path(commentable)
    if commentable.is_a?(Place)
      place_path(commentable)
    else
      stay_path(commentable)
    end
  end
end
