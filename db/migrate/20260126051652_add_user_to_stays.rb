class AddUserToStays < ActiveRecord::Migration[8.0]
  def change
    add_reference :stays, :user, null: true, foreign_key: true
  end
end
