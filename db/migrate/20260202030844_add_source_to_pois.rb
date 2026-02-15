class AddSourceToPois < ActiveRecord::Migration[8.0]
  def change
    add_column :pois, :source, :string, default: 'osm'
    add_index :pois, [ :stay_id, :foursquare_id ], unique: true, where: "foursquare_id IS NOT NULL", name: 'index_pois_on_stay_id_and_foursquare_id'
  end
end
