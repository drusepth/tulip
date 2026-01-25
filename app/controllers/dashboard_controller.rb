class DashboardController < ApplicationController
  def index
    Stay.update_all_statuses!

    @current_stay = Stay.current_stay
    @next_stay = Stay.next_upcoming
    @total_stays = Stay.count
    @countries_visited = Stay.distinct.pluck(:country).compact.count
    @gaps = Stay.find_gaps
    @recent_stays = Stay.past.limit(3)
    @upcoming_stays = Stay.upcoming.limit(5)
  end
end
