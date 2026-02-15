require "test_helper"

class WeatherServiceTest < ActiveSupport::TestCase
  setup do
    WebMock.disable_net_connect!
    @lat = 40.7128
    @lng = -74.0060
    @start_date = Date.new(2026, 1, 15)
    @end_date = Date.new(2026, 1, 20)
  end

  teardown do
    WebMock.allow_net_connect!
  end

  test "fetch_historical_weather returns structured data for valid response" do
    stub_weather_api_success

    result = WeatherService.fetch_historical_weather(
      lat: @lat,
      lng: @lng,
      start_date: @start_date,
      end_date: @end_date
    )

    assert_not_nil result
    assert_equal 30, result[:low]
    assert_equal 50, result[:high]
    assert_equal 40, result[:average]
    assert_includes result[:conditions].keys, "Sunny"
    assert_includes result[:conditions].keys, "Rainy"
  end

  test "fetch_historical_weather returns nil for API error" do
    stub_request(:get, /archive-api.open-meteo.com/)
      .to_return(status: 500, body: "Internal Server Error")

    result = WeatherService.fetch_historical_weather(
      lat: @lat,
      lng: @lng,
      start_date: @start_date,
      end_date: @end_date
    )

    assert_nil result
  end

  test "fetch_historical_weather returns nil for network error" do
    stub_request(:get, /archive-api.open-meteo.com/)
      .to_timeout

    result = WeatherService.fetch_historical_weather(
      lat: @lat,
      lng: @lng,
      start_date: @start_date,
      end_date: @end_date
    )

    assert_nil result
  end

  test "fetch_historical_weather queries previous year data" do
    expected_start = (@start_date - 1.year).to_s
    expected_end = (@end_date - 1.year).to_s

    stub = stub_request(:get, /archive-api.open-meteo.com/)
      .with(query: hash_including(
        "start_date" => expected_start,
        "end_date" => expected_end
      ))
      .to_return(status: 200, body: api_response_body.to_json)

    WeatherService.fetch_historical_weather(
      lat: @lat,
      lng: @lng,
      start_date: @start_date,
      end_date: @end_date
    )

    assert_requested stub
  end

  test "weather codes are grouped correctly" do
    response = {
      "daily" => {
        "temperature_2m_max" => [ 50, 55, 60 ],
        "temperature_2m_min" => [ 30, 35, 40 ],
        "weather_code" => [ 0, 61, 95 ]  # Sunny, Rainy, Stormy
      }
    }

    stub_request(:get, /archive-api.open-meteo.com/)
      .to_return(status: 200, body: response.to_json)

    result = WeatherService.fetch_historical_weather(
      lat: @lat,
      lng: @lng,
      start_date: @start_date,
      end_date: @end_date
    )

    assert_equal({ "Sunny" => 1, "Rainy" => 1, "Stormy" => 1 }, result[:conditions])
  end

  private

  def stub_weather_api_success
    stub_request(:get, /archive-api.open-meteo.com/)
      .to_return(status: 200, body: api_response_body.to_json)
  end

  def api_response_body
    {
      "daily" => {
        "time" => [ "2025-01-15", "2025-01-16", "2025-01-17", "2025-01-18", "2025-01-19", "2025-01-20" ],
        "temperature_2m_max" => [ 45, 48, 50, 47, 46, 49 ],
        "temperature_2m_min" => [ 30, 32, 35, 33, 31, 34 ],
        "weather_code" => [ 0, 1, 2, 61, 63, 0 ]
      }
    }
  end
end
