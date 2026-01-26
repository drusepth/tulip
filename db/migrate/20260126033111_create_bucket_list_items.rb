class CreateBucketListItems < ActiveRecord::Migration[8.0]
  def change
    create_table :bucket_list_items do |t|
      t.references :stay, null: false, foreign_key: true
      t.string :title, null: false
      t.string :category, default: 'other'
      t.text :notes
      t.string :address
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.boolean :completed, default: false, null: false
      t.datetime :completed_at
      t.integer :position

      t.timestamps
    end

    add_index :bucket_list_items, [:stay_id, :completed]
    add_index :bucket_list_items, [:stay_id, :category]
  end
end
