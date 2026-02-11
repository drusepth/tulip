class CreatePlacesAndRefactorPois < ActiveRecord::Migration[8.0]
  def change
    create_table :places do |t|
      t.string :osm_id
      t.string :name
      t.string :category
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.string :address
      t.string :opening_hours
      t.string :website
      t.string :phone
      t.string :cuisine
      t.boolean :outdoor_seating
      t.string :internet_access
      t.boolean :air_conditioning
      t.boolean :takeaway
      t.string :brand
      t.text :description
      t.string :source, default: "osm"

      # Foursquare enrichment
      t.string :foursquare_id
      t.decimal :foursquare_rating, precision: 3, scale: 1
      t.integer :foursquare_price
      t.string :foursquare_photo_url
      t.text :foursquare_tip
      t.datetime :foursquare_fetched_at

      # Wikidata enrichment
      t.string :wikidata_id
      t.string :wikipedia_url
      t.text :wikipedia_extract
      t.string :wikidata_image_url
      t.datetime :wikidata_fetched_at

      t.timestamps
    end

    add_index :places, :osm_id, unique: true
    add_index :places, :category
    add_index :places, :foursquare_id
    add_index :places, :wikidata_id

    # Add place_id to pois (thin join table)
    add_reference :pois, :place, foreign_key: true

    # Add place_id to viewport_pois
    add_reference :viewport_pois, :place, foreign_key: true

    # Remove notes from pois
    remove_column :pois, :notes, :text

    # Remove canonical data columns from pois (now on places)
    remove_column :pois, :name, :string
    remove_column :pois, :latitude, :decimal, precision: 10, scale: 6
    remove_column :pois, :longitude, :decimal, precision: 10, scale: 6
    remove_column :pois, :address, :string
    remove_column :pois, :opening_hours, :string
    remove_column :pois, :website, :string
    remove_column :pois, :phone, :string
    remove_column :pois, :cuisine, :string
    remove_column :pois, :outdoor_seating, :boolean
    remove_column :pois, :internet_access, :string
    remove_column :pois, :air_conditioning, :boolean
    remove_column :pois, :takeaway, :boolean
    remove_column :pois, :brand, :string
    remove_column :pois, :description, :text
    remove_column :pois, :source, :string
    remove_column :pois, :foursquare_id, :string
    remove_column :pois, :foursquare_rating, :decimal
    remove_column :pois, :foursquare_price, :integer
    remove_column :pois, :foursquare_photo_url, :string
    remove_column :pois, :foursquare_tip, :text
    remove_column :pois, :foursquare_fetched_at, :datetime
    remove_column :pois, :wikidata_id, :string
    remove_column :pois, :wikipedia_url, :string
    remove_column :pois, :wikipedia_extract, :text
    remove_column :pois, :wikidata_image_url, :string
    remove_column :pois, :wikidata_fetched_at, :datetime

    # Remove osm_id from pois (now on places via place_id)
    remove_index :pois, :osm_id
    remove_column :pois, :osm_id, :string

    # Remove canonical data columns from viewport_pois (now on places)
    remove_column :viewport_pois, :name, :string
    remove_column :viewport_pois, :latitude, :decimal, precision: 10, scale: 6
    remove_column :viewport_pois, :longitude, :decimal, precision: 10, scale: 6
    remove_column :viewport_pois, :address, :string
    remove_column :viewport_pois, :opening_hours, :string
    remove_column :viewport_pois, :website, :string
    remove_column :viewport_pois, :phone, :string
    remove_column :viewport_pois, :cuisine, :string
    remove_column :viewport_pois, :outdoor_seating, :boolean
    remove_column :viewport_pois, :internet_access, :string
    remove_column :viewport_pois, :air_conditioning, :boolean
    remove_column :viewport_pois, :takeaway, :boolean
    remove_column :viewport_pois, :brand, :string
    remove_column :viewport_pois, :description, :text
    remove_column :viewport_pois, :foursquare_id, :string
    remove_column :viewport_pois, :foursquare_rating, :decimal
    remove_column :viewport_pois, :foursquare_price, :integer
    remove_column :viewport_pois, :foursquare_photo_url, :string
    remove_column :viewport_pois, :foursquare_tip, :text
    remove_column :viewport_pois, :foursquare_fetched_at, :datetime
    remove_column :viewport_pois, :wikidata_id, :string
    remove_column :viewport_pois, :wikipedia_url, :string
    remove_column :viewport_pois, :wikipedia_extract, :text
    remove_column :viewport_pois, :wikidata_image_url, :string
    remove_column :viewport_pois, :wikidata_fetched_at, :datetime

    # Remove osm_id from viewport_pois (now on places via place_id)
    remove_index :viewport_pois, column: [:grid_key, :osm_id]
    remove_column :viewport_pois, :osm_id, :string

    # Add unique index on viewport_pois for grid_key + place_id
    add_index :viewport_pois, [:grid_key, :place_id], unique: true
  end
end
