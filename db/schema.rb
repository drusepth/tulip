# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_01_26_012815) do
  create_table "pois", force: :cascade do |t|
    t.integer "stay_id", null: false
    t.string "name"
    t.string "category"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.integer "distance_meters"
    t.string "osm_id"
    t.string "address"
    t.string "opening_hours"
    t.boolean "favorite", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["osm_id"], name: "index_pois_on_osm_id", unique: true
    t.index ["stay_id", "category"], name: "index_pois_on_stay_id_and_category"
    t.index ["stay_id"], name: "index_pois_on_stay_id"
  end

  create_table "stays", force: :cascade do |t|
    t.string "title", null: false
    t.string "stay_type", default: "airbnb"
    t.string "booking_url"
    t.string "image_url"
    t.string "address"
    t.string "city"
    t.string "country"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.date "check_in", null: false
    t.date "check_out", null: false
    t.integer "price_total_cents"
    t.string "currency", default: "USD"
    t.text "notes"
    t.string "status", default: "upcoming"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "state"
    t.boolean "booked", default: false, null: false
    t.index ["check_in", "check_out"], name: "index_stays_on_check_in_and_check_out"
  end

  create_table "transit_routes", force: :cascade do |t|
    t.integer "stay_id", null: false
    t.string "name"
    t.string "route_type"
    t.string "color"
    t.string "osm_id"
    t.text "geometry"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["osm_id"], name: "index_transit_routes_on_osm_id", unique: true
    t.index ["stay_id", "route_type"], name: "index_transit_routes_on_stay_id_and_route_type"
    t.index ["stay_id"], name: "index_transit_routes_on_stay_id"
  end

  add_foreign_key "pois", "stays"
  add_foreign_key "transit_routes", "stays"
end
