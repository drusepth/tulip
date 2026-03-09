module Api
  module V1
    class ScratchMapController < BaseController
      STATE_ABBREV_TO_NAME = {
        "AL" => "Alabama", "AK" => "Alaska", "AZ" => "Arizona", "AR" => "Arkansas",
        "CA" => "California", "CO" => "Colorado", "CT" => "Connecticut", "DE" => "Delaware",
        "FL" => "Florida", "GA" => "Georgia", "HI" => "Hawaii", "ID" => "Idaho",
        "IL" => "Illinois", "IN" => "Indiana", "IA" => "Iowa", "KS" => "Kansas",
        "KY" => "Kentucky", "LA" => "Louisiana", "ME" => "Maine", "MD" => "Maryland",
        "MA" => "Massachusetts", "MI" => "Michigan", "MN" => "Minnesota", "MS" => "Mississippi",
        "MO" => "Missouri", "MT" => "Montana", "NE" => "Nebraska", "NV" => "Nevada",
        "NH" => "New Hampshire", "NJ" => "New Jersey", "NM" => "New Mexico", "NY" => "New York",
        "NC" => "North Carolina", "ND" => "North Dakota", "OH" => "Ohio", "OK" => "Oklahoma",
        "OR" => "Oregon", "PA" => "Pennsylvania", "RI" => "Rhode Island", "SC" => "South Carolina",
        "SD" => "South Dakota", "TN" => "Tennessee", "TX" => "Texas", "UT" => "Utah",
        "VT" => "Vermont", "VA" => "Virginia", "WA" => "Washington", "WV" => "West Virginia",
        "WI" => "Wisconsin", "WY" => "Wyoming", "DC" => "District of Columbia"
      }.freeze

      def index
        user_stays = current_user.accessible_stays

        # Include all stays with a state (past, current, and upcoming)
        all_stays_with_state = user_stays.where.not(state: [nil, ""])
                                         .order(:check_in)

        # Group by full state name (convert abbreviations)
        stays_by_state = all_stays_with_state.group_by { |s| STATE_ABBREV_TO_NAME[s.state.upcase] || s.state }
        # Remove nil keys (states that couldn't be mapped)
        stays_by_state = stays_by_state.reject { |k, _| k.nil? }

        # Count only visited states (past or current) for the total
        visited_states = all_stays_with_state.select { |s| s.status.in?(%w[past current]) }
                                             .map { |s| STATE_ABBREV_TO_NAME[s.state.upcase] || s.state }
                                             .compact
                                             .uniq

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
          total_visited: visited_states.size,
          total_states: 50
        }
      end
    end
  end
end
