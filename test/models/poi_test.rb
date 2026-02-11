require "test_helper"

class PoiTest < ActiveSupport::TestCase
  test "delegates name to place" do
    poi = pois(:one)
    assert_equal "Blue Bottle Coffee", poi.name
  end

  test "delegates coordinates to place" do
    poi = pois(:one)
    assert_equal poi.place.latitude, poi.latitude
    assert_equal poi.place.longitude, poi.longitude
  end

  test "belongs to stay and place" do
    poi = pois(:one)
    assert poi.stay.present?
    assert poi.place.present?
  end
end
