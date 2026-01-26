class ViewportPoi < ApplicationRecord
  GRID_SIZE = 0.01 # ~1km grid cells

  validates :grid_key, presence: true
  validates :category, inclusion: { in: Poi::CATEGORIES }
  validates :osm_id, uniqueness: { scope: :grid_key }, allow_nil: true

  scope :by_grid_key, ->(key) { where(grid_key: key) }
  scope :by_category, ->(category) { where(category: category) }

  class << self
    def grid_key_for(lat:, lng:, category:)
      rounded_lat = (lat.to_f / GRID_SIZE).floor * GRID_SIZE
      rounded_lng = (lng.to_f / GRID_SIZE).floor * GRID_SIZE
      "#{category}:#{format('%.2f', rounded_lat)}:#{format('%.2f', rounded_lng)}"
    end

    def grid_center_for(lat:, lng:)
      rounded_lat = (lat.to_f / GRID_SIZE).floor * GRID_SIZE
      rounded_lng = (lng.to_f / GRID_SIZE).floor * GRID_SIZE
      # Return center of the grid cell
      {
        lat: rounded_lat + (GRID_SIZE / 2),
        lng: rounded_lng + (GRID_SIZE / 2)
      }
    end

    def cached_for_grid?(grid_key)
      by_grid_key(grid_key).exists?
    end
  end

  def coordinates
    [latitude, longitude]
  end
end
