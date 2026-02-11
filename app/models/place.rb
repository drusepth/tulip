class Place < ApplicationRecord
  CATEGORIES = %w[bus_stops stations coffee grocery gym food coworking library parks].freeze
  BROWSABLE_CATEGORIES = %w[coffee grocery food gym coworking library parks].freeze
  SOURCES = %w[osm foursquare].freeze

  has_many :pois, dependent: :nullify
  has_many :viewport_pois, dependent: :nullify
  has_many :stays, through: :pois

  validates :category, inclusion: { in: CATEGORIES }
  validates :osm_id, uniqueness: true, allow_nil: true
  validates :source, inclusion: { in: SOURCES }, allow_nil: true

  scope :by_category, ->(category) { where(category: category) }
  scope :with_photos, -> { where.not(foursquare_photo_url: nil) }

  def coordinates
    [latitude, longitude]
  end

  # Find or create a Place from Overpass data, returning the Place record
  def self.find_or_create_from_overpass(poi_data, category:)
    find_or_create_by(osm_id: poi_data[:osm_id]) do |place|
      place.assign_attributes(
        name: poi_data[:name],
        category: category,
        latitude: poi_data[:latitude],
        longitude: poi_data[:longitude],
        address: poi_data[:address],
        opening_hours: poi_data[:opening_hours],
        website: poi_data[:website],
        phone: poi_data[:phone],
        cuisine: poi_data[:cuisine],
        outdoor_seating: poi_data[:outdoor_seating],
        internet_access: poi_data[:internet_access],
        air_conditioning: poi_data[:air_conditioning],
        takeaway: poi_data[:takeaway],
        brand: poi_data[:brand],
        description: poi_data[:description],
        wikidata_id: poi_data[:wikidata]
      )
    end
  end
end
