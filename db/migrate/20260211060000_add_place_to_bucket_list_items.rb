class AddPlaceToBucketListItems < ActiveRecord::Migration[8.0]
  def change
    add_reference :bucket_list_items, :place, null: true, foreign_key: true
  end
end
