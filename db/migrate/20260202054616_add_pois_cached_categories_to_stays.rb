class AddPoisCachedCategoriesToStays < ActiveRecord::Migration[8.0]
  def change
    add_column :stays, :pois_cached_categories, :text, default: [].to_yaml
  end
end
