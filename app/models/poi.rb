class Poi < ApplicationRecord
  belongs_to :stay
  belongs_to :place

  validates :category, inclusion: { in: Place::CATEGORIES }

  # Delegate canonical data to place
  delegate :name, :latitude, :longitude, :address, :opening_hours, :website,
           :phone, :cuisine, :outdoor_seating, :outdoor_seating?, :internet_access,
           :air_conditioning, :air_conditioning?, :takeaway, :takeaway?,
           :brand, :description, :source, :osm_id,
           :foursquare_id, :foursquare_rating, :foursquare_price,
           :foursquare_photo_url, :foursquare_tip, :foursquare_fetched_at,
           :wikidata_id, :wikipedia_url, :wikipedia_extract,
           :wikidata_image_url, :wikidata_fetched_at,
           :coordinates,
           to: :place, allow_nil: true

  scope :by_category, ->(category) { where(category: category) }
  scope :favorites, -> { where(favorite: true) }
  scope :nearest, -> { order(:distance_meters) }
end
