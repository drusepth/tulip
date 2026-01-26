class WeatherService
  ARCHIVE_API_URL = 'https://archive-api.open-meteo.com/v1/archive'.freeze

  # WMO Weather Code groupings
  WEATHER_CODE_LABELS = {
    0 => 'Clear', 1 => 'Clear',
    2 => 'Cloudy', 3 => 'Cloudy',
    45 => 'Foggy', 48 => 'Foggy',
    51 => 'Rainy', 53 => 'Rainy', 55 => 'Rainy',
    61 => 'Rainy', 63 => 'Rainy', 65 => 'Rainy',
    80 => 'Rainy', 81 => 'Rainy', 82 => 'Rainy',
    71 => 'Snowy', 73 => 'Snowy', 75 => 'Snowy',
    85 => 'Snowy', 86 => 'Snowy',
    95 => 'Stormy', 96 => 'Stormy', 99 => 'Stormy'
  }.freeze

  class << self
    def fetch_historical_weather(lat:, lng:, start_date:, end_date:)
      # Query previous year's data for the same date range
      historical_start = start_date - 1.year
      historical_end = end_date - 1.year

      response = make_request(lat, lng, historical_start, historical_end)
      return nil unless response

      parse_response(response)
    end

    private

    def make_request(lat, lng, start_date, end_date)
      params = {
        latitude: lat,
        longitude: lng,
        start_date: start_date.to_s,
        end_date: end_date.to_s,
        daily: 'temperature_2m_max,temperature_2m_min,weather_code',
        temperature_unit: 'fahrenheit',
        timezone: 'auto'
      }

      Rails.logger.info("Weather API request: #{ARCHIVE_API_URL} with params #{params}")

      response = HTTParty.get(
        ARCHIVE_API_URL,
        query: params,
        timeout: 30
      )

      unless response.success?
        Rails.logger.error("Weather API returned #{response.code}: #{response.body[0..200]}")
        return nil
      end

      JSON.parse(response.body)
    rescue StandardError => e
      Rails.logger.error("Weather API error: #{e.message}")
      nil
    end

    def parse_response(response)
      daily = response['daily']
      return nil unless daily

      max_temps = daily['temperature_2m_max']&.compact || []
      min_temps = daily['temperature_2m_min']&.compact || []
      weather_codes = daily['weather_code']&.compact || []

      return nil if max_temps.empty? || min_temps.empty?

      # Calculate overall low, high, and average
      overall_low = min_temps.min.round
      overall_high = max_temps.max.round

      # Average of daily averages
      daily_averages = max_temps.zip(min_temps).map { |max, min| (max + min) / 2.0 }
      average = (daily_averages.sum / daily_averages.size).round

      # Count weather conditions
      conditions = count_conditions(weather_codes)

      {
        low: overall_low,
        high: overall_high,
        average: average,
        conditions: conditions
      }
    end

    def count_conditions(weather_codes)
      counts = Hash.new(0)

      weather_codes.each do |code|
        label = WEATHER_CODE_LABELS[code] || 'Clear'
        counts[label] += 1
      end

      # Sort by count descending
      counts.sort_by { |_, count| -count }.to_h
    end
  end
end
