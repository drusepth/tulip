require "test_helper"

class StayTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    # Clear existing stays for clean tests
    @user.stays.destroy_all
  end

  test "should_geocode when address changes even if coordinates already exist" do
    stay = @user.stays.create!(
      title: "Test Stay",
      city: "Portland",
      country: "USA",
      check_in: Date.new(2027, 1, 1),
      check_out: Date.new(2027, 1, 10),
      latitude: 45.5155,
      longitude: -122.6789
    )

    stay.address = "123 Main St"
    assert stay.send(:should_geocode?), "should_geocode? should return true when address changes even with existing coordinates"
  end

  test "should_geocode when city changes even if coordinates already exist" do
    stay = @user.stays.create!(
      title: "Test Stay",
      city: "Portland",
      country: "USA",
      check_in: Date.new(2027, 1, 1),
      check_out: Date.new(2027, 1, 10),
      latitude: 45.5155,
      longitude: -122.6789
    )

    stay.city = "Seattle"
    assert stay.send(:should_geocode?), "should_geocode? should return true when city changes even with existing coordinates"
  end

  test "should not geocode when no location fields changed" do
    stay = @user.stays.create!(
      title: "Test Stay",
      city: "Portland",
      country: "USA",
      check_in: Date.new(2027, 1, 1),
      check_out: Date.new(2027, 1, 10),
      latitude: 45.5155,
      longitude: -122.6789
    )

    stay.title = "Updated Title"
    assert_not stay.send(:should_geocode?), "should_geocode? should return false when only non-location fields change"
  end

  test "clears cached POIs and transit routes when location changes" do
    stay = @user.stays.create!(
      title: "Test Stay",
      city: "Portland",
      country: "USA",
      check_in: Date.new(2027, 1, 1),
      check_out: Date.new(2027, 1, 10)
    )

    # Create some cached POIs and transit routes
    stay.pois.create!(name: "Coffee Shop", category: "coffee", latitude: 45.516, longitude: -122.679, distance_meters: 100, osm_id: "test_poi_1")
    stay.pois.create!(name: "Grocery Store", category: "grocery", latitude: 45.517, longitude: -122.680, distance_meters: 200, osm_id: "test_poi_2")
    stay.transit_routes.create!(name: "Bus 14", route_type: "bus", osm_id: "test_route_1")
    stay.update_columns(weather_data: '{"temp": 50}', weather_fetched_at: Time.current)

    assert_equal 2, stay.pois.count
    assert_equal 1, stay.transit_routes.count
    assert stay.weather_data.present?

    # Stub geocoder to return different coordinates for the new city
    Geocoder::Lookup::Test.add_stub("Seattle, USA", [
      { "latitude" => 47.6062, "longitude" => -122.3321, "city" => "Seattle", "country" => "USA" }
    ])

    # Update city — geocoder will produce new lat/lng, triggering cache clear
    stay.update!(city: "Seattle")

    assert_equal 0, stay.pois.count
    assert_equal 0, stay.transit_routes.count
    stay.reload
    assert_nil stay.weather_data
    assert_nil stay.weather_fetched_at
  end

  test "does not clear cached POIs when non-location fields change" do
    stay = @user.stays.create!(
      title: "Test Stay",
      city: "Portland",
      country: "USA",
      check_in: Date.new(2027, 1, 1),
      check_out: Date.new(2027, 1, 10)
    )

    stay.pois.create!(name: "Coffee Shop", category: "coffee", latitude: 45.516, longitude: -122.679, distance_meters: 100, osm_id: "test_poi_3")

    stay.update!(title: "Updated Title", notes: "New notes")

    assert_equal 1, stay.pois.count
  end

  test "find_gaps returns empty array when no stays" do
    assert_equal [], @user.stays.find_gaps
  end

  test "find_gaps returns empty array with single stay" do
    @user.stays.create!(
      title: "Solo Trip",
      city: "Portland",
      country: "USA",
      check_in: Date.new(2027, 1, 1),
      check_out: Date.new(2027, 1, 10)
    )

    assert_equal [], @user.stays.find_gaps
  end

  test "find_gaps detects gap between consecutive non-overlapping stays" do
    @user.stays.create!(
      title: "Trip 1",
      city: "Portland",
      country: "USA",
      check_in: Date.new(2027, 1, 1),
      check_out: Date.new(2027, 1, 10)
    )
    @user.stays.create!(
      title: "Trip 2",
      city: "Seattle",
      country: "USA",
      check_in: Date.new(2027, 1, 20),
      check_out: Date.new(2027, 1, 30)
    )

    gaps = @user.stays.find_gaps

    assert_equal 1, gaps.length
    assert_equal :gap, gaps.first[:type]
    assert_equal Date.new(2027, 1, 10), gaps.first[:start_date]
    assert_equal Date.new(2027, 1, 20), gaps.first[:end_date]
    assert_equal 10, gaps.first[:days]
  end

  test "find_gaps returns no gap when stays are back-to-back" do
    @user.stays.create!(
      title: "Trip 1",
      city: "Portland",
      country: "USA",
      check_in: Date.new(2027, 1, 1),
      check_out: Date.new(2027, 1, 10)
    )
    @user.stays.create!(
      title: "Trip 2",
      city: "Seattle",
      country: "USA",
      check_in: Date.new(2027, 1, 10),
      check_out: Date.new(2027, 1, 20)
    )

    assert_equal [], @user.stays.find_gaps
  end

  test "find_gaps ignores overlapping stay within longer stay" do
    # Long stay: Jan 1 - Jun 30 (Kansas City scenario)
    @user.stays.create!(
      title: "Long Stay",
      city: "Kansas City",
      country: "USA",
      check_in: Date.new(2027, 1, 1),
      check_out: Date.new(2027, 6, 30)
    )

    # Overlapping stay in the middle: Mar 15 - Apr 15 (Amsterdam scenario)
    # Skip validation since this overlaps
    amsterdam = @user.stays.new(
      title: "Amsterdam Trip",
      city: "Amsterdam",
      country: "Netherlands",
      check_in: Date.new(2027, 3, 15),
      check_out: Date.new(2027, 4, 15)
    )
    amsterdam.save!(validate: false)

    # Next stay after long stay ends
    @user.stays.create!(
      title: "Chicago",
      city: "Chicago",
      country: "USA",
      check_in: Date.new(2027, 7, 1),
      check_out: Date.new(2027, 7, 15)
    )

    gaps = @user.stays.find_gaps

    # Should only have one gap: Jun 30 -> Jul 1 (1 day)
    # NOT Apr 15 -> Jul 1 (which would be wrong)
    assert_equal 1, gaps.length
    assert_equal Date.new(2027, 6, 30), gaps.first[:start_date]
    assert_equal Date.new(2027, 7, 1), gaps.first[:end_date]
    assert_equal 1, gaps.first[:days]
  end

  test "find_gaps handles multiple overlapping stays correctly" do
    # Base stay: Jan 1 - Jan 31
    @user.stays.create!(
      title: "Base Stay",
      city: "Denver",
      country: "USA",
      check_in: Date.new(2027, 1, 1),
      check_out: Date.new(2027, 1, 31)
    )

    # Overlapping stay that extends coverage: Jan 15 - Feb 15
    overlap = @user.stays.new(
      title: "Extended Stay",
      city: "Boulder",
      country: "USA",
      check_in: Date.new(2027, 1, 15),
      check_out: Date.new(2027, 2, 15)
    )
    overlap.save!(validate: false)

    # Next stay with gap
    @user.stays.create!(
      title: "Next Stay",
      city: "Seattle",
      country: "USA",
      check_in: Date.new(2027, 3, 1),
      check_out: Date.new(2027, 3, 15)
    )

    gaps = @user.stays.find_gaps

    # Gap should be Feb 15 -> Mar 1 (14 days), using max_check_out from overlapping stay
    assert_equal 1, gaps.length
    assert_equal Date.new(2027, 2, 15), gaps.first[:start_date]
    assert_equal Date.new(2027, 3, 1), gaps.first[:end_date]
    assert_equal 14, gaps.first[:days]
  end
end
