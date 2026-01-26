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
end
