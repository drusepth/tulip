require "test_helper"

class OverpassServiceTest < ActiveSupport::TestCase
  setup do
    WebMock.disable_net_connect!
    @lat = 45.565
    @lng = -122.635
  end

  teardown do
    WebMock.allow_net_connect!
  end

  test "fetch_pois returns parsed POI data for valid response" do
    stub_overpass_success(poi_response_body)

    result = OverpassService.fetch_pois(lat: @lat, lng: @lng, category: "coffee")

    assert_kind_of Array, result
    assert_equal 1, result.length
    assert_equal "Test Cafe", result.first[:name]
    assert_equal 45.566, result.first[:latitude]
    assert_equal(-122.636, result.first[:longitude])
  end

  test "fetch_pois returns empty array for unknown category" do
    result = OverpassService.fetch_pois(lat: @lat, lng: @lng, category: "nonexistent")

    assert_equal [], result
  end

  test "fetch_pois retries on 429 and succeeds with different endpoint" do
    # First endpoint returns 429, second succeeds
    stubs = stub_all_endpoints
    stubs.each_with_index do |s, i|
      if i == 0
        s.to_return(status: 429, body: "Rate limited")
          .then
          .to_return(status: 200, body: poi_response_body.to_json)
      else
        s.to_return(status: 200, body: poi_response_body.to_json)
      end
    end

    result = OverpassService.fetch_pois(lat: @lat, lng: @lng, category: "coffee")

    assert_equal 1, result.length
    assert_equal "Test Cafe", result.first[:name]
  end

  test "fetch_pois retries on 504 and succeeds" do
    stubs = stub_all_endpoints
    stubs.each_with_index do |s, i|
      if i == 0
        s.to_return(status: 504, body: "Gateway Timeout")
          .then
          .to_return(status: 200, body: poi_response_body.to_json)
      else
        s.to_return(status: 200, body: poi_response_body.to_json)
      end
    end

    result = OverpassService.fetch_pois(lat: @lat, lng: @lng, category: "coffee")

    assert_equal 1, result.length
  end

  test "fetch_pois raises RateLimitedError after exhausting retries on 429" do
    stub_all_endpoints.each { |s| s.to_return(status: 429, body: "Rate limited") }

    assert_raises(OverpassService::RateLimitedError) do
      OverpassService.fetch_pois(lat: @lat, lng: @lng, category: "coffee")
    end
  end

  test "fetch_pois raises RateLimitedError after exhausting retries on 504" do
    stub_all_endpoints.each { |s| s.to_return(status: 504, body: "Gateway Timeout") }

    assert_raises(OverpassService::RateLimitedError) do
      OverpassService.fetch_pois(lat: @lat, lng: @lng, category: "coffee")
    end
  end

  test "fetch_pois returns empty array on non-rate-limit errors" do
    stub_all_endpoints.each { |s| s.to_return(status: 500, body: "Internal Server Error") }

    result = OverpassService.fetch_pois(lat: @lat, lng: @lng, category: "coffee")

    assert_equal [], result
  end

  test "fetch_pois returns empty array on network timeout" do
    stub_all_endpoints.each(&:to_timeout)

    result = OverpassService.fetch_pois(lat: @lat, lng: @lng, category: "coffee")

    assert_equal [], result
  end

  test "fetch_transit_routes raises RateLimitedError on persistent 429" do
    stub_all_endpoints.each { |s| s.to_return(status: 429, body: "Rate limited") }

    assert_raises(OverpassService::RateLimitedError) do
      OverpassService.fetch_transit_routes(lat: @lat, lng: @lng, route_type: "bus")
    end
  end

  private

  def stub_overpass_success(body)
    OverpassService::OVERPASS_ENDPOINTS.each do |url|
      stub_request(:post, url)
        .to_return(status: 200, body: body.to_json)
    end
  end

  def stub_all_endpoints
    OverpassService::OVERPASS_ENDPOINTS.map do |url|
      stub_request(:post, url)
    end
  end

  def poi_response_body
    {
      "elements" => [
        {
          "type" => "node",
          "id" => 123456,
          "lat" => 45.566,
          "lon" => -122.636,
          "tags" => {
            "name" => "Test Cafe",
            "amenity" => "cafe",
            "addr:street" => "Main St",
            "addr:housenumber" => "123",
            "opening_hours" => "Mo-Fr 07:00-18:00"
          }
        }
      ]
    }
  end
end
