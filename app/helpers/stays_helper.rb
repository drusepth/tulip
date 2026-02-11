module StaysHelper
  def weather_icon(condition)
    case condition.to_s
    when "Clear" then "☀️"
    when "Cloudy" then "☁️"
    when "Foggy" then "🌫️"
    when "Rainy" then "🌧️"
    when "Snowy" then "❄️"
    when "Stormy" then "⛈️"
    else "🌤️"
    end
  end

  def weather_card_class(condition)
    case condition.to_s
    when "Clear" then "weather-card-sunny"
    when "Cloudy" then "weather-card-cloudy"
    when "Foggy" then "weather-card-foggy"
    when "Rainy" then "weather-card-rainy"
    when "Snowy" then "weather-card-snowy"
    when "Stormy" then "weather-card-stormy"
    else "weather-card-cloudy"
    end
  end

  def weather_bubble_class(condition)
    case condition.to_s
    when "Clear" then "weather-bubble-sunny"
    when "Cloudy" then "weather-bubble-cloudy"
    when "Foggy" then "weather-bubble-foggy"
    when "Rainy" then "weather-bubble-rainy"
    when "Snowy" then "weather-bubble-snowy"
    when "Stormy" then "weather-bubble-stormy"
    else "weather-bubble-cloudy"
    end
  end
end
