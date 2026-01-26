class AddBookedToStays < ActiveRecord::Migration[8.0]
  def change
    add_column :stays, :booked, :boolean, default: false, null: false
  end
end
