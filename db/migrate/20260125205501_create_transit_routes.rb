class CreateTransitRoutes < ActiveRecord::Migration[8.0]
  def change
    create_table :transit_routes do |t|
      t.references :stay, null: false, foreign_key: true
      t.string :name
      t.string :route_type
      t.string :color
      t.string :osm_id
      t.text :geometry

      t.timestamps
    end

    add_index :transit_routes, [ :stay_id, :route_type ]
    add_index :transit_routes, :osm_id, unique: true
  end
end
