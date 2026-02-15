class AddSpatialIndexToPlaces < ActiveRecord::Migration[8.0]
  def change
    add_index :places, [ :latitude, :longitude ], name: 'index_places_on_lat_lng'
  end
end
