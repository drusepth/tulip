module ApplicationHelper
  def format_distance(meters)
    miles = meters / 1609.34
    if miles < 0.1
      "#{(miles * 5280).round} ft"
    else
      "#{miles.round(1)} mi"
    end
  end
end
