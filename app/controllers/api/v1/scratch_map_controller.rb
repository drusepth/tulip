module Api
  module V1
    class ScratchMapController < BaseController
      def index
        user_stays = current_user.accessible_stays
        completed = user_stays.past.or(user_stays.current)
        stays_by_state = completed.where.not(state: [nil, ""])
                                  .order(:check_in)
                                  .group_by(&:state)

        states = {}
        stays_by_state.each do |state, stays|
          states[state] = {
            count: stays.size,
            stays: stays.map { |stay|
              {
                id: stay.id,
                title: stay.title,
                city: stay.city,
                check_in: stay.check_in,
                check_out: stay.check_out,
                image_url: stay.image_url,
                status: stay.status,
                duration_days: stay.duration_days
              }
            }
          }
        end

        render json: {
          states: states,
          total_visited: states.keys.size,
          total_states: 50
        }
      end
    end
  end
end
