class AddBucketListItemRatingToComments < ActiveRecord::Migration[8.0]
  def change
    add_reference :comments, :bucket_list_item_rating, null: true, foreign_key: true
  end
end
