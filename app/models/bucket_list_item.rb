class BucketListItem < ApplicationRecord
  CATEGORIES = %w[activity landmark restaurant experience shopping nightlife nature other].freeze

  belongs_to :stay
  belongs_to :user, optional: true
  belongs_to :place, optional: true
  has_many :ratings, class_name: "BucketListItemRating", dependent: :destroy

  before_validation :set_title_from_address

  validate :title_or_address_present
  validates :category, inclusion: { in: CATEGORIES }

  scope :pending, -> { where(completed: false) }
  scope :completed, -> { where(completed: true) }
  scope :by_category, ->(category) { where(category: category) }
  scope :with_location, -> { where.not(latitude: nil, longitude: nil) }
  scope :ordered, -> { order(:position, :created_at) }

  geocoded_by :address
  after_validation :geocode, if: :should_geocode?

  def toggle_completed!
    if completed?
      update!(completed: false, completed_at: nil)
    else
      update!(completed: true, completed_at: Time.current)
    end
  end

  def coordinates
    [ latitude, longitude ] if latitude.present? && longitude.present?
  end

  def has_location?
    latitude.present? && longitude.present?
  end

  def rating_for(user)
    ratings.find_by(user: user)
  end

  private

  def set_title_from_address
    if title.blank? && address.present?
      self.title = address
    end
  end

  def title_or_address_present
    if title.blank? && address.blank?
      errors.add(:base, "Title or address must be provided")
    end
  end

  def should_geocode?
    address.present? && address_changed? && (latitude.blank? || longitude.blank?)
  end
end
