ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "webmock/minitest"

# Disable external HTTP connections in tests - use stubs instead
WebMock.disable_net_connect!(allow_localhost: true)

# Configure Geocoder to use test stubs instead of real API calls
Geocoder.configure(lookup: :test, ip_lookup: :test)
Geocoder::Lookup::Test.set_default_stub(
  [
    {
      "coordinates" => [40.7128, -74.0060],
      "address" => "New York, NY, USA",
      "city" => "New York",
      "state" => "New York",
      "state_code" => "NY",
      "country" => "United States",
      "country_code" => "US"
    }
  ]
)

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...

    # Stub external API calls for each test
    setup do
      # Stub Open-Meteo weather API calls
      stub_request(:get, /archive-api\.open-meteo\.com/).to_return(
        status: 200,
        body: {
          daily: {
            time: ["2025-03-04", "2025-03-05", "2025-03-06"],
            temperature_2m_max: [65.0, 68.0, 70.0],
            temperature_2m_min: [50.0, 52.0, 55.0],
            weather_code: [0, 1, 2],
            apparent_temperature_max: [63.0, 66.0, 68.0],
            apparent_temperature_min: [48.0, 50.0, 53.0],
            precipitation_sum: [0.0, 0.0, 0.1],
            precipitation_hours: [0, 0, 1],
            wind_speed_10m_max: [10.0, 12.0, 8.0],
            wind_gusts_10m_max: [15.0, 18.0, 12.0],
            sunrise: ["06:30", "06:29", "06:28"],
            sunset: ["18:15", "18:16", "18:17"]
          }
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
    end
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
