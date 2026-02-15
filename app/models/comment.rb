class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :user
  belongs_to :parent, class_name: "Comment", optional: true
  belongs_to :bucket_list_item_rating, optional: true

  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy

  validates :body, presence: true, length: { maximum: 2000 }, unless: :rating_comment?
  validate :parent_must_be_top_level

  scope :top_level, -> { where(parent_id: nil) }
  scope :ordered, -> { order(created_at: :asc) }
  scope :rating_comments, -> { where.not(bucket_list_item_rating_id: nil) }

  after_create_commit :notify_on_create, unless: :rating_comment?
  after_create_commit :notify_mentions

  delegate :bucket_list_item, to: :bucket_list_item_rating, allow_nil: true

  # Convenience accessor for backward compatibility
  def stay
    commentable if commentable_type == "Stay"
  end

  def rating_comment?
    bucket_list_item_rating_id.present?
  end

  def editable_by?(check_user)
    return false unless check_user
    user_id == check_user.id
  end

  def edited?
    updated_at > created_at + 1.second
  end

  private

  def notify_on_create
    if parent_id?
      NotificationService.reply_created(self)
    else
      NotificationService.comment_created(self)
    end
  end

  def notify_mentions
    stay = self.stay
    return unless stay

    mentioned_ids = ApplicationHelper.extract_mentioned_user_ids(body, stay: stay)
    return if mentioned_ids.empty?

    NotificationService.user_mentioned(self, mentioned_user_ids: mentioned_ids, actor: user)
  end

  def parent_must_be_top_level
    return unless parent.present?
    if parent.parent_id.present?
      errors.add(:parent, "must be a top-level comment (no nested replies)")
    end
  end
end
