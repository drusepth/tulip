class TimelineController < ApplicationController
  def index
    @stays = current_user.stays.chronological
    @gaps = find_gaps(@stays)

    if @stays.any?
      @start_date = [@stays.first.check_in, Date.current - 30].min
      @end_date = [@stays.last.check_out, Date.current + 90].max
      @total_days = (@end_date - @start_date).to_i
    else
      @start_date = Date.current - 30
      @end_date = Date.current + 90
      @total_days = 120
    end

    @today = Date.current
  end

  private

  def find_gaps(stays)
    gaps = []
    ordered_stays = stays.to_a
    ordered_stays.each_cons(2) do |stay1, stay2|
      if stay2.check_in > stay1.check_out
        gaps << {
          start_date: stay1.check_out,
          end_date: stay2.check_in,
          days: (stay2.check_in - stay1.check_out).to_i
        }
      end
    end
    gaps
  end
end
