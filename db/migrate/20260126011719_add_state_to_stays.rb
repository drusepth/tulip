class AddStateToStays < ActiveRecord::Migration[8.0]
  def change
    add_column :stays, :state, :string
  end
end
