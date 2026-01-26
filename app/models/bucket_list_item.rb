class BucketListItem < ApplicationRecord
  CATEGORIES = %w[activity landmark restaurant experience shopping nightlife nature other].freeze

  belongs_to :stay

  validates :title, presence: true
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
    [latitude, longitude] if latitude.present? && longitude.present?
  end

  def has_location?
    latitude.present? && longitude.present?
  end

  private

  def should_geocode?
    address.present? && address_changed? && (latitude.blank? || longitude.blank?)
  end
end
