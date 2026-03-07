class ScratchMapController < ApplicationController
  def show
    user_stays = current_user.accessible_stays
    completed = user_stays.past.or(user_stays.current)
    @visited_states = completed.where.not(state: [nil, ""]).reorder(nil).distinct.pluck(:state).compact
    @total_visited = @visited_states.count
  end
end
