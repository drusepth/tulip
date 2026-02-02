require "test_helper"

class FetchBrowsablePoisJobTest < ActiveJob::TestCase
  setup do
    @stay = stays(:one)
    @stay.update_column(:pois_cached_categories, [])

    stub_request(:post, "https://overpass-api.de/api/interpreter").to_return(
      status: 200,
      body: {
        elements: [
          {
            type: "node",
            id: 123456,
            lat: 37.7750,
            lon: -122.4195,
            tags: {
              name: "Test Coffee Shop",
              amenity: "cafe",
              "addr:street": "Market St",
              "addr:housenumber": "100"
            }
          }
        ]
      }.to_json,
      headers: { "Content-Type" => "application/json" }
    )
  end

  test "fetches POIs for all browsable categories" do
    FetchBrowsablePoisJob.perform_now(@stay.id)

    @stay.reload
    assert_equal Poi::BROWSABLE_CATEGORIES.sort, @stay.pois_cached_categories.sort
  end

  test "skips already cached categories" do
    @stay.update_column(:pois_cached_categories, ["coffee", "food"])

    FetchBrowsablePoisJob.perform_now(@stay.id)

    @stay.reload
    # Should have original cached categories plus the rest
    assert_includes @stay.pois_cached_categories, "coffee"
    assert_includes @stay.pois_cached_categories, "food"
    assert_includes @stay.pois_cached_categories, "grocery"
  end

  test "handles missing stay gracefully" do
    assert_nothing_raised do
      FetchBrowsablePoisJob.perform_now(-1)
    end
  end

  test "skips stay without coordinates" do
    @stay.update_columns(latitude: nil, longitude: nil)

    assert_nothing_raised do
      FetchBrowsablePoisJob.perform_now(@stay.id)
    end

    @stay.reload
    assert_empty @stay.pois_cached_categories
  end

  test "creates POIs from fetched data" do
    initial_count = @stay.pois.count

    FetchBrowsablePoisJob.perform_now(@stay.id)

    # Should have created POIs (one per category from our stub)
    assert @stay.pois.count > initial_count
  end
end
