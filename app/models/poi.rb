class Poi < ApplicationRecord
  CATEGORIES = %w[bus_stops stations coffee grocery gym food coworking library parks].freeze
  BROWSABLE_CATEGORIES = %w[coffee grocery food gym coworking library parks stations].freeze
  SOURCES = %w[osm foursquare].freeze

  belongs_to :stay

  validates :category, inclusion: { in: CATEGORIES }
  validates :osm_id, uniqueness: true, allow_nil: true
  validates :foursquare_id, uniqueness: { scope: :stay_id }, allow_nil: true
  validates :source, inclusion: { in: SOURCES }, allow_nil: true

  scope :by_category, ->(category) { where(category: category) }
  scope :favorites, -> { where(favorite: true) }
  scope :nearest, -> { order(:distance_meters) }
  scope :from_foursquare, -> { where(source: 'foursquare') }
  scope :with_photos, -> { where.not(foursquare_photo_url: nil) }

  def coordinates
    [latitude, longitude]
  end
end
