class DashboardController < ApplicationController
  def index
    Stay.update_all_statuses!

    # Alerts (only shown when action needed)
    @gaps = Stay.find_gaps
    @booking_alert = Stay.booking_alert

    # Hero section: Current & Next
    @current_stay = Stay.current_stay
    @next_stay = Stay.next_upcoming

    # Upcoming stays timeline (all upcoming, with images)
    @upcoming_stays = Stay.upcoming

    # Secondary: Stats & Recent
    @total_stays = Stay.count
    @states_visited = Stay.distinct.pluck(:state).compact.count
    @recent_stays = Stay.past.limit(5)
  end
end
