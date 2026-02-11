class CleanUpOrphanedPoisAndRequirePlace < ActiveRecord::Migration[8.0]
  def up
    # Remove POIs and ViewportPOIs that have no associated place
    Poi.where(place_id: nil).delete_all
    ViewportPoi.where(place_id: nil).delete_all

    # Remove POIs and ViewportPOIs referencing places that no longer exist
    Poi.where.not(place_id: Place.select(:id)).delete_all
    ViewportPoi.where.not(place_id: Place.select(:id)).delete_all

    # Now enforce NOT NULL on place_id
    change_column_null :pois, :place_id, false
    change_column_null :viewport_pois, :place_id, false
  end

  def down
    change_column_null :pois, :place_id, true
    change_column_null :viewport_pois, :place_id, true
  end
end
