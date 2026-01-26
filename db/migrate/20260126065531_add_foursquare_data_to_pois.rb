class AddFoursquareDataToPois < ActiveRecord::Migration[8.0]
  def change
    # Add Foursquare enrichment fields to pois table
    add_column :pois, :foursquare_id, :string
    add_column :pois, :foursquare_rating, :decimal, precision: 3, scale: 1
    add_column :pois, :foursquare_price, :integer
    add_column :pois, :foursquare_photo_url, :string
    add_column :pois, :foursquare_tip, :text
    add_column :pois, :foursquare_fetched_at, :datetime

    add_index :pois, :foursquare_id

    # Add same fields to viewport_pois table
    add_column :viewport_pois, :foursquare_id, :string
    add_column :viewport_pois, :foursquare_rating, :decimal, precision: 3, scale: 1
    add_column :viewport_pois, :foursquare_price, :integer
    add_column :viewport_pois, :foursquare_photo_url, :string
    add_column :viewport_pois, :foursquare_tip, :text
    add_column :viewport_pois, :foursquare_fetched_at, :datetime

    add_index :viewport_pois, :foursquare_id
  end
end
