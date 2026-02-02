class CreateBucketListItemRatings < ActiveRecord::Migration[8.0]
  def change
    create_table :bucket_list_item_ratings do |t|
      t.references :bucket_list_item, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :rating, null: false

      t.timestamps
    end

    add_index :bucket_list_item_ratings, [:bucket_list_item_id, :user_id], unique: true, name: 'index_bucket_list_item_ratings_unique'
  end
end
