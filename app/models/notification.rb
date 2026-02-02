class Notification < ApplicationRecord
  TYPES = %w[
    comment_on_stay
    reply_to_comment
    bucket_list_completed
    bucket_list_rated
    collaboration_invited
    collaboration_accepted
  ].freeze

  belongs_to :user
  belongs_to :notifiable, polymorphic: true, optional: true

  validates :notification_type, presence: true, inclusion: { in: TYPES }

  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc).limit(20) }
  scope :by_date, -> { order(created_at: :desc) }

  def mark_as_read!
    update!(read_at: Time.current) unless read?
  end

  def read?
    read_at.present?
  end

  def unread?
    !read?
  end

  def icon_name
    case notification_type
    when "comment_on_stay", "reply_to_comment"
      "chat_bubble"
    when "bucket_list_completed"
      "check_circle"
    when "bucket_list_rated"
      "star"
    when "collaboration_invited", "collaboration_accepted"
      "users"
    else
      "bell"
    end
  end

  def ring_color
    case notification_type
    when "comment_on_stay", "reply_to_comment"
      "lavender"
    when "bucket_list_completed"
      "sage"
    when "bucket_list_rated"
      "coral"
    when "collaboration_invited", "collaboration_accepted"
      "rose"
    else
      "taupe"
    end
  end

  def message
    case notification_type
    when "comment_on_stay"
      actor_name = data["actor_name"] || "Someone"
      stay_title = data["stay_title"] || "a stay"
      "#{actor_name} commented on #{stay_title}"
    when "reply_to_comment"
      actor_name = data["actor_name"] || "Someone"
      "#{actor_name} replied to your comment"
    when "bucket_list_completed"
      actor_name = data["actor_name"] || "Someone"
      item_title = data["item_title"] || "an item"
      "#{actor_name} completed \"#{item_title}\""
    when "bucket_list_rated"
      actor_name = data["actor_name"] || "Someone"
      item_title = data["item_title"] || "an item"
      rating = data["rating"] || "?"
      "#{actor_name} rated \"#{item_title}\" #{rating} stars"
    when "collaboration_invited"
      stay_title = data["stay_title"] || "a stay"
      "You've been invited to collaborate on #{stay_title}"
    when "collaboration_accepted"
      actor_name = data["actor_name"] || "Someone"
      stay_title = data["stay_title"] || "a stay"
      "#{actor_name} joined #{stay_title}"
    else
      "You have a new notification"
    end
  end

  def target_path
    case notification_type
    when "comment_on_stay", "reply_to_comment"
      stay_id = data["stay_id"]
      return nil unless stay_id
      Rails.application.routes.url_helpers.stay_path(stay_id, anchor: "comments")
    when "bucket_list_completed", "bucket_list_rated"
      stay_id = data["stay_id"]
      return nil unless stay_id
      Rails.application.routes.url_helpers.stay_path(stay_id, anchor: "bucket-list")
    when "collaboration_invited", "collaboration_accepted"
      stay_id = data["stay_id"]
      return nil unless stay_id
      Rails.application.routes.url_helpers.stay_path(stay_id)
    else
      nil
    end
  end

  def data
    super || {}
  end
end
