class TimelineController < ApplicationController
  def index
    @stays = Stay.chronological
    @gaps = Stay.find_gaps

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
end
