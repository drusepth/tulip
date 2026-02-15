class CreatePois < ActiveRecord::Migration[8.0]
  def change
    create_table :pois do |t|
      t.references :stay, null: false, foreign_key: true
      t.string :name
      t.string :category
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.integer :distance_meters
      t.string :osm_id
      t.string :address
      t.string :opening_hours
      t.boolean :favorite, default: false

      t.timestamps
    end

    add_index :pois, [ :stay_id, :category ]
    add_index :pois, :osm_id, unique: true
  end
end
