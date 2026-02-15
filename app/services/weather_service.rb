class WeatherService
  ARCHIVE_API_URL = "https://archive-api.open-meteo.com/v1/archive".freeze

  # WMO Weather Code groupings
  WEATHER_CODE_LABELS = {
    0 => "Sunny", 1 => "Sunny",
    2 => "Cloudy", 3 => "Cloudy",
    45 => "Foggy", 48 => "Foggy",
    51 => "Rainy", 53 => "Rainy", 55 => "Rainy",
    61 => "Rainy", 63 => "Rainy", 65 => "Rainy",
    80 => "Rainy", 81 => "Rainy", 82 => "Rainy",
    71 => "Snowy", 73 => "Snowy", 75 => "Snowy",
    85 => "Snowy", 86 => "Snowy",
    95 => "Stormy", 96 => "Stormy", 99 => "Stormy"
  }.freeze

  MAX_YEARS_BACK = 5

  class << self
    def fetch_historical_weather(lat:, lng:, start_date:, end_date:)
      # Try previous years until we find data (up to MAX_YEARS_BACK)
      (1..MAX_YEARS_BACK).each do |years_ago|
        historical_start = start_date - years_ago.years
        historical_end = end_date - years_ago.years

        # Skip if the historical end date is still in the future
        next if historical_end > Date.today

        Rails.logger.info("Trying weather data from #{years_ago} year(s) ago: #{historical_start} to #{historical_end}")

        response = make_request(lat, lng, historical_start, historical_end)
        next unless response

        result = parse_response(response)
        return result if result.present?
      end

      nil
    end

    private

    def make_request(lat, lng, start_date, end_date)
      params = {
        latitude: lat,
        longitude: lng,
        start_date: start_date.to_s,
        end_date: end_date.to_s,
        daily: "temperature_2m_max,temperature_2m_min,weather_code,apparent_temperature_max,apparent_temperature_min,precipitation_sum,precipitation_hours,wind_speed_10m_max,wind_gusts_10m_max,sunrise,sunset",
        temperature_unit: "fahrenheit",
        timezone: "auto"
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
      daily = response["daily"]
      return nil unless daily

      dates = daily["time"] || []
      max_temps = daily["temperature_2m_max"]&.compact || []
      min_temps = daily["temperature_2m_min"]&.compact || []
      weather_codes = daily["weather_code"]&.compact || []
      apparent_max = daily["apparent_temperature_max"] || []
      apparent_min = daily["apparent_temperature_min"] || []
      precipitation_sum = daily["precipitation_sum"] || []
      precipitation_hours = daily["precipitation_hours"] || []
      wind_speed_max = daily["wind_speed_10m_max"] || []
      wind_gusts_max = daily["wind_gusts_10m_max"] || []
      sunrise_times = daily["sunrise"] || []
      sunset_times = daily["sunset"] || []

      return nil if max_temps.empty? || min_temps.empty?

      # Calculate overall low, high, and average
      overall_low = min_temps.min.round
      overall_high = max_temps.max.round

      # Average of daily averages
      daily_averages = max_temps.zip(min_temps).map { |max, min| (max + min) / 2.0 }
      average = (daily_averages.sum / daily_averages.size).round

      # Count weather conditions
      conditions = count_conditions(weather_codes)

      # Build per-day data
      daily_data = dates.each_with_index.map do |date, i|
        next if max_temps[i].nil? || min_temps[i].nil?

        {
          date: date,
          high: max_temps[i]&.round,
          low: min_temps[i]&.round,
          condition: WEATHER_CODE_LABELS[weather_codes[i]] || "Sunny",
          feels_like_high: apparent_max[i]&.round,
          feels_like_low: apparent_min[i]&.round,
          precipitation_mm: precipitation_sum[i]&.round(1),
          precipitation_hours: precipitation_hours[i]&.round,
          wind_speed: wind_speed_max[i]&.round,
          wind_gusts: wind_gusts_max[i]&.round,
          sunrise: sunrise_times[i],
          sunset: sunset_times[i]
        }
      end.compact

      {
        low: overall_low,
        high: overall_high,
        average: average,
        conditions: conditions,
        daily_data: daily_data
      }
    end

    def count_conditions(weather_codes)
      counts = Hash.new(0)

      weather_codes.each do |code|
        label = WEATHER_CODE_LABELS[code] || "Sunny"
        counts[label] += 1
      end

      # Sort by count descending
      counts.sort_by { |_, count| -count }.to_h
    end
  end
end
