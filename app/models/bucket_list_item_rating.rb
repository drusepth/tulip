class BucketListItemRating < ApplicationRecord
  belongs_to :bucket_list_item
  belongs_to :user
  has_one :comment, dependent: :destroy

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :user_id, uniqueness: { scope: :bucket_list_item_id, message: "has already rated this item" }
  validate :item_must_be_completed

  after_create :create_rating_comment

  private

  def item_must_be_completed
    return unless bucket_list_item

    unless bucket_list_item.completed?
      errors.add(:base, "Cannot rate an incomplete bucket list item")
    end
  end

  def create_rating_comment
    create_comment!(
      stay: bucket_list_item.stay,
      user: user,
      bucket_list_item_rating: self
    )
  end
end
