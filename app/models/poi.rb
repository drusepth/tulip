class Poi < ApplicationRecord
  CATEGORIES = %w[transit_stops coffee veterinarian grocery].freeze

  belongs_to :stay

  validates :category, inclusion: { in: CATEGORIES }
  validates :osm_id, uniqueness: true, allow_nil: true

  scope :by_category, ->(category) { where(category: category) }
  scope :favorites, -> { where(favorite: true) }
  scope :nearest, -> { order(:distance_meters) }

  def coordinates
    [latitude, longitude]
  end
end
