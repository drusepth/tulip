class AddWikidataFieldsToPois < ActiveRecord::Migration[8.0]
  def change
    add_column :pois, :wikidata_id, :string
    add_column :pois, :wikipedia_url, :string
    add_column :pois, :wikipedia_extract, :text
    add_column :pois, :wikidata_image_url, :string
    add_column :pois, :wikidata_fetched_at, :datetime

    add_index :pois, :wikidata_id

    add_column :viewport_pois, :wikidata_id, :string
    add_column :viewport_pois, :wikipedia_url, :string
    add_column :viewport_pois, :wikipedia_extract, :text
    add_column :viewport_pois, :wikidata_image_url, :string
    add_column :viewport_pois, :wikidata_fetched_at, :datetime

    add_index :viewport_pois, :wikidata_id
  end
end
