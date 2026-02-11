require "test_helper"

class PlaceTest < ActiveSupport::TestCase
  test "has valid fixtures" do
    place = places(:blue_bottle)
    assert_equal "Blue Bottle Coffee", place.name
    assert_equal "coffee", place.category
    assert_equal "osm_123456", place.osm_id
  end

  test "validates category inclusion" do
    place = Place.new(name: "Test", category: "invalid")
    assert_not place.valid?
    assert_includes place.errors[:category], "is not included in the list"
  end

  test "validates osm_id uniqueness" do
    existing = places(:blue_bottle)
    duplicate = Place.new(name: "Dupe", category: "coffee", osm_id: existing.osm_id)
    assert_not duplicate.valid?
  end

  test "find_or_create_from_overpass creates new place" do
    data = {
      osm_id: "node/999999",
      name: "New Place",
      latitude: 40.0,
      longitude: -74.0,
      address: "123 Test St"
    }

    assert_difference "Place.count", 1 do
      place = Place.find_or_create_from_overpass(data, category: "coffee")
      assert_equal "New Place", place.name
      assert_equal "coffee", place.category
    end
  end

  test "find_or_create_from_overpass finds existing place" do
    existing = places(:blue_bottle)
    data = {
      osm_id: existing.osm_id,
      name: "Different Name",
      latitude: 37.0,
      longitude: -122.0
    }

    assert_no_difference "Place.count" do
      place = Place.find_or_create_from_overpass(data, category: "coffee")
      assert_equal existing.id, place.id
    end
  end

  test "has many pois" do
    place = places(:blue_bottle)
    assert_includes place.pois, pois(:one)
  end
end
