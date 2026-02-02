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

ActiveRecord::Schema[8.0].define(version: 2026_02_02_030844) do
  create_table "bucket_list_items", force: :cascade do |t|
    t.integer "stay_id", null: false
    t.string "title", null: false
    t.string "category", default: "other"
    t.text "notes"
    t.string "address"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.boolean "completed", default: false, null: false
    t.datetime "completed_at"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["stay_id", "category"], name: "index_bucket_list_items_on_stay_id_and_category"
    t.index ["stay_id", "completed"], name: "index_bucket_list_items_on_stay_id_and_completed"
    t.index ["stay_id"], name: "index_bucket_list_items_on_stay_id"
    t.index ["user_id"], name: "index_bucket_list_items_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.integer "stay_id", null: false
    t.integer "user_id", null: false
    t.integer "parent_id"
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index ["stay_id", "created_at"], name: "index_comments_on_stay_id_and_created_at"
    t.index ["stay_id"], name: "index_comments_on_stay_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

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
    t.string "website"
    t.string "phone"
    t.string "cuisine"
    t.boolean "outdoor_seating"
    t.string "internet_access"
    t.boolean "air_conditioning"
    t.boolean "takeaway"
    t.string "brand"
    t.text "description"
    t.string "foursquare_id"
    t.decimal "foursquare_rating", precision: 3, scale: 1
    t.integer "foursquare_price"
    t.string "foursquare_photo_url"
    t.text "foursquare_tip"
    t.datetime "foursquare_fetched_at"
    t.string "source", default: "osm"
    t.index ["foursquare_id"], name: "index_pois_on_foursquare_id"
    t.index ["osm_id"], name: "index_pois_on_osm_id", unique: true
    t.index ["stay_id", "category"], name: "index_pois_on_stay_id_and_category"
    t.index ["stay_id", "foursquare_id"], name: "index_pois_on_stay_id_and_foursquare_id", unique: true, where: "foursquare_id IS NOT NULL"
    t.index ["stay_id"], name: "index_pois_on_stay_id"
  end

  create_table "stay_collaborations", force: :cascade do |t|
    t.integer "stay_id", null: false
    t.integer "user_id"
    t.string "role", default: "editor", null: false
    t.string "invite_token"
    t.datetime "invite_accepted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invite_token"], name: "index_stay_collaborations_on_invite_token", unique: true
    t.index ["stay_id", "user_id"], name: "index_stay_collaborations_on_stay_id_and_user_id", unique: true, where: "user_id IS NOT NULL"
    t.index ["stay_id"], name: "index_stay_collaborations_on_stay_id"
    t.index ["user_id"], name: "index_stay_collaborations_on_user_id"
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
    t.date "check_in"
    t.date "check_out"
    t.integer "price_total_cents"
    t.string "currency", default: "USD"
    t.text "notes"
    t.string "status", default: "upcoming"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "state"
    t.boolean "booked", default: false, null: false
    t.text "weather_data"
    t.datetime "weather_fetched_at"
    t.integer "user_id"
    t.json "destination_images", default: []
    t.datetime "images_fetched_at"
    t.index ["check_in", "check_out"], name: "index_stays_on_check_in_and_check_out"
    t.index ["user_id"], name: "index_stays_on_user_id"
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

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "viewport_pois", force: :cascade do |t|
    t.string "grid_key", null: false
    t.string "name"
    t.string "category", null: false
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "osm_id"
    t.string "address"
    t.string "opening_hours"
    t.decimal "center_lat", precision: 10, scale: 6
    t.decimal "center_lng", precision: 10, scale: 6
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "website"
    t.string "phone"
    t.string "cuisine"
    t.boolean "outdoor_seating"
    t.string "internet_access"
    t.boolean "air_conditioning"
    t.boolean "takeaway"
    t.string "brand"
    t.text "description"
    t.string "foursquare_id"
    t.decimal "foursquare_rating", precision: 3, scale: 1
    t.integer "foursquare_price"
    t.string "foursquare_photo_url"
    t.text "foursquare_tip"
    t.datetime "foursquare_fetched_at"
    t.index ["category"], name: "index_viewport_pois_on_category"
    t.index ["foursquare_id"], name: "index_viewport_pois_on_foursquare_id"
    t.index ["grid_key", "osm_id"], name: "index_viewport_pois_on_grid_key_and_osm_id", unique: true
    t.index ["grid_key"], name: "index_viewport_pois_on_grid_key"
  end

  add_foreign_key "bucket_list_items", "stays"
  add_foreign_key "bucket_list_items", "users"
  add_foreign_key "comments", "comments", column: "parent_id"
  add_foreign_key "comments", "stays"
  add_foreign_key "comments", "users"
  add_foreign_key "pois", "stays"
  add_foreign_key "stay_collaborations", "stays"
  add_foreign_key "stay_collaborations", "users"
  add_foreign_key "stays", "users"
  add_foreign_key "transit_routes", "stays"
end
