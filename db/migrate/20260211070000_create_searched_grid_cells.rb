class CreateSearchedGridCells < ActiveRecord::Migration[8.0]
  def change
    create_table :searched_grid_cells do |t|
      t.string :grid_key, null: false
      t.string :category, null: false
      t.datetime :searched_at, null: false

      t.timestamps
    end

    add_index :searched_grid_cells, :grid_key, unique: true
    add_index :searched_grid_cells, :category
    add_index :searched_grid_cells, [:category, :searched_at]
  end
end
