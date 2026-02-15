class TransitRoute < ApplicationRecord
  ROUTE_TYPES = %w[rails train ferry bus].freeze

  belongs_to :stay

  validates :route_type, inclusion: { in: ROUTE_TYPES }
  validates :osm_id, uniqueness: true, allow_nil: true

  scope :by_type, ->(type) { where(route_type: type) }
  scope :rails, -> { by_type("rails") }
  scope :train, -> { by_type("train") }
  scope :ferry, -> { by_type("ferry") }
  scope :bus, -> { by_type("bus") }

  def geometry_coordinates
    return [] unless geometry
    JSON.parse(geometry)
  rescue JSON::ParserError
    []
  end
end
