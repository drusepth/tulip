class AddUserToBucketListItems < ActiveRecord::Migration[8.0]
  def change
    add_reference :bucket_list_items, :user, foreign_key: true
  end
end
