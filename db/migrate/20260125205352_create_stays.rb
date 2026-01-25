class CreateStays < ActiveRecord::Migration[8.0]
  def change
    create_table :stays do |t|
      t.string :title, null: false
      t.string :stay_type, default: 'airbnb'
      t.string :booking_url
      t.string :image_url
      t.string :address
      t.string :city
      t.string :country
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.date :check_in, null: false
      t.date :check_out, null: false
      t.integer :price_total_cents
      t.string :currency, default: 'USD'
      t.text :notes
      t.string :status, default: 'upcoming'

      t.timestamps
    end

    add_index :stays, [:check_in, :check_out]
  end
end
