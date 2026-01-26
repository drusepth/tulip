class AddDetailsToPois < ActiveRecord::Migration[8.0]
  def change
    # Add detail fields to pois table
    add_column :pois, :website, :string
    add_column :pois, :phone, :string
    add_column :pois, :cuisine, :string
    add_column :pois, :outdoor_seating, :boolean
    add_column :pois, :internet_access, :string
    add_column :pois, :air_conditioning, :boolean
    add_column :pois, :takeaway, :boolean
    add_column :pois, :brand, :string
    add_column :pois, :description, :text

    # Add same fields to viewport_pois table
    add_column :viewport_pois, :website, :string
    add_column :viewport_pois, :phone, :string
    add_column :viewport_pois, :cuisine, :string
    add_column :viewport_pois, :outdoor_seating, :boolean
    add_column :viewport_pois, :internet_access, :string
    add_column :viewport_pois, :air_conditioning, :boolean
    add_column :viewport_pois, :takeaway, :boolean
    add_column :viewport_pois, :brand, :string
    add_column :viewport_pois, :description, :text
  end
end
