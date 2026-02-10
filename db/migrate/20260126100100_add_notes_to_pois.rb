class AddNotesToPois < ActiveRecord::Migration[8.0]
  def change
    add_column :pois, :notes, :text
  end
end
