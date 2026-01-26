class AddWeatherToStays < ActiveRecord::Migration[8.0]
  def change
    add_column :stays, :weather_data, :text
    add_column :stays, :weather_fetched_at, :datetime
  end
end
