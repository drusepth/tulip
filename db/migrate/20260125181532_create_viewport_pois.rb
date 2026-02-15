class CreateViewportPois < ActiveRecord::Migration[8.0]
  def change
    create_table :viewport_pois do |t|
      t.string :grid_key, null: false
      t.string :name
      t.string :category, null: false
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.string :osm_id
      t.string :address
      t.string :opening_hours
      t.decimal :center_lat, precision: 10, scale: 6
      t.decimal :center_lng, precision: 10, scale: 6

      t.timestamps
    end

    add_index :viewport_pois, :grid_key
    add_index :viewport_pois, [ :grid_key, :osm_id ], unique: true
    add_index :viewport_pois, :category
  end
end
