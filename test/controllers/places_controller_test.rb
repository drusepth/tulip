require "test_helper"

class PlacesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
    @place = places(:blue_bottle)
  end

  # Place search tests
  test "place_search returns matching nearby places" do
    # Create a nearby place to find
    nearby = Place.create!(
      name: "Nearby Cafe",
      category: "coffee",
      latitude: @place.latitude + 0.001,
      longitude: @place.longitude + 0.001,
      osm_id: "osm_nearby_test"
    )

    get place_search_place_path(@place), params: { q: "Nearby" }, as: :json
    assert_response :success
    results = JSON.parse(response.body)
    assert results.any? { |r| r["id"] == nearby.id }
  end

  test "place_search excludes the current place from results" do
    get place_search_place_path(@place), params: { q: @place.name.first(4) }, as: :json
    assert_response :success
    results = JSON.parse(response.body)
    assert_not results.any? { |r| r["id"] == @place.id }
  end

  test "place_search returns empty for non-matching query" do
    get place_search_place_path(@place), params: { q: "zzzznotfound" }, as: :json
    assert_response :success
    results = JSON.parse(response.body)
    assert_empty results
  end

  test "place_search returns empty with blank query" do
    get place_search_place_path(@place), params: { q: "" }, as: :json
    assert_response :success
    results = JSON.parse(response.body)
    assert_empty results
  end

  test "place_search requires authentication" do
    sign_out @user
    get place_search_place_path(@place), params: { q: "Coffee" }, as: :json
    assert_includes [ 302, 401 ], response.status
  end
end
