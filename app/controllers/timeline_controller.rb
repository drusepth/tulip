class TimelineController < ApplicationController
  def index
    @stays = current_user.stays.chronological
    @gaps = @stays.find_gaps
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

  def build_timeline_items(stays, gaps)
    items = []
    rows = []  # Array of arrays, each containing end_dates for that row

    # Add stays as timeline items with row assignment
    stays.each do |stay|
      # Find first row where this stay fits (no overlap)
      row_index = rows.find_index { |row| row.all? { |end_date| stay.check_in >= end_date } }

      if row_index.nil?
        # Need a new row
        row_index = rows.length
        rows << []
      end

      rows[row_index] << stay.check_out

      items << {
        type: :stay,
        object: stay,
        start_date: stay.check_in,
        end_date: stay.check_out,
        row: row_index
      }
    end

    # Gaps only appear on row 0 (between non-overlapping stays)
    gaps.each do |gap|
      items << gap.merge(row: 0)
    end

    # Store total row count for view
    @row_count = [ rows.length, 1 ].max

    # Sort by start date
    items.sort_by { |item| item[:start_date] }
  end
end
