class TimelineController < ApplicationController
  def index
    @stays = current_user.stays.chronological
    @gaps = find_gaps(@stays)
    @today = Date.current

    # Calculate default date range based on stays
    if @stays.any?
      default_start = [@stays.first.check_in, Date.current - 30].min
      default_end = [@stays.last.check_out, Date.current + 90].max
    else
      default_start = Date.current - 30
      default_end = Date.current + 90
    end

    # Handle zoom query params
    @zoom = params[:zoom] || "all"
    case @zoom
    when "3m"
      @start_date = @today - 45
      @end_date = @today + 45
    when "year"
      @start_date = @today.beginning_of_year
      @end_date = @today.end_of_year
    else # "all"
      @start_date = default_start
      @end_date = default_end
    end

    @total_days = [(@end_date - @start_date).to_i, 1].max

    # Build chronologically sorted timeline items (stays and gaps interleaved)
    @timeline_items = build_timeline_items(@stays, @gaps)
  end

  private

  def find_gaps(stays)
    gaps = []
    ordered_stays = stays.to_a
    ordered_stays.each_cons(2) do |stay1, stay2|
      if stay2.check_in > stay1.check_out
        gaps << {
          type: :gap,
          start_date: stay1.check_out,
          end_date: stay2.check_in,
          days: (stay2.check_in - stay1.check_out).to_i
        }
      end
    end
    gaps
  end

  def build_timeline_items(stays, gaps)
    items = []

    # Add stays as timeline items
    stays.each do |stay|
      items << {
        type: :stay,
        object: stay,
        start_date: stay.check_in,
        end_date: stay.check_out
      }
    end

    # Add gaps as timeline items
    gaps.each do |gap|
      items << gap
    end

    # Sort by start date
    items.sort_by { |item| item[:start_date] }
  end
end
