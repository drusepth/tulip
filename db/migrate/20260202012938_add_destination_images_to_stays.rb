class AddDestinationImagesToStays < ActiveRecord::Migration[8.0]
  def change
    add_column :stays, :destination_images, :jsonb, default: []
    add_column :stays, :images_fetched_at, :datetime
  end
end
