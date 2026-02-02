class TimelineController < ApplicationController
  def index
    # Only include stays with dates on the timeline (exclude wishlist items)
    # Eager load associations for statistics and enhanced tooltips
    @stays = current_user.accessible_stays.with_dates.chronological
                         .includes(:bucket_list_items, :stay_collaborations)
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
    when "6m"
      @start_date = @today - 90
      @end_date = @today + 90
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

    # Calculate statistics for the summary panel
    @statistics = calculate_statistics(@stays, @gaps)

    # Calculate season boundaries for visual dividers
    @season_boundaries = calculate_season_boundaries(@start_date, @end_date)

    # Prepare data for year grid view (if toggled)
    @view_mode = params[:view] || "timeline"
    if @view_mode == "year_grid"
      prepare_year_grid_data
    end
  end

  private

  def calculate_statistics(stays, gaps)
    return {} if stays.empty?

    # Filter stays visible in current view
    visible_stays = stays.select { |s| s.check_out >= @start_date && s.check_in <= @end_date }
    visible_gaps = gaps.select { |g| g[:end_date] >= @start_date && g[:start_date] <= @end_date }

    # Calculate nights in view (clamp to visible range)
    total_nights = visible_stays.sum do |stay|
      visible_start = [stay.check_in, @start_date].max
      visible_end = [stay.check_out, @end_date].min
      (visible_end - visible_start).to_i
    end

    # Calculate gap days in view
    total_gap_days = visible_gaps.sum do |gap|
      visible_start = [gap[:start_date], @start_date].max
      visible_end = [gap[:end_date], @end_date].min
      (visible_end - visible_start).to_i
    end

    # Geographic stats
    countries = visible_stays.map(&:country).compact.uniq.reject(&:blank?)
    cities = visible_stays.map(&:city).compact.uniq.reject(&:blank?)

    # Cost stats (only for stays with price data)
    stays_with_price = visible_stays.select { |s| s.price_total_cents.present? && s.price_total_cents > 0 }
    total_cost_cents = stays_with_price.sum(&:price_total_cents)
    total_priced_nights = stays_with_price.sum(&:duration_days)

    avg_per_night_cents = if total_priced_nights > 0
      (total_cost_cents / total_priced_nights.to_f).round
    else
      0
    end

    # Price range
    prices_per_night = stays_with_price.map { |s| s.price_total_cents / [s.duration_days, 1].max }
    min_price_cents = prices_per_night.min || 0
    max_price_cents = prices_per_night.max || 0

    # Currency (use most common)
    primary_currency = visible_stays.map(&:currency).compact.group_by(&:itself)
                                    .max_by { |_, v| v.size }&.first || "USD"

    # Stay types breakdown
    stay_types = visible_stays.group_by(&:stay_type).transform_values(&:count)

    # Average stay length
    avg_stay_length = visible_stays.any? ? (visible_stays.sum(&:duration_days) / visible_stays.count.to_f).round(1) : 0

    {
      total_nights: total_nights,
      total_gap_days: total_gap_days,
      gap_percentage: @total_days > 0 ? ((total_gap_days / @total_days.to_f) * 100).round(1) : 0,
      countries: countries,
      country_count: countries.count,
      cities: cities,
      city_count: cities.count,
      total_cost_cents: total_cost_cents,
      avg_per_night_cents: avg_per_night_cents,
      min_price_cents: min_price_cents,
      max_price_cents: max_price_cents,
      primary_currency: primary_currency,
      has_price_data: stays_with_price.any?,
      stay_types: stay_types,
      avg_stay_length: avg_stay_length,
      stay_count: visible_stays.count
    }
  end

  def calculate_season_boundaries(start_date, end_date)
    boundaries = []
    current_year = start_date.year

    while current_year <= end_date.year
      # Season start dates (Northern Hemisphere)
      seasons = [
        { date: Date.new(current_year, 3, 20), season: :spring, icon: "flower", label: "Spring" },
        { date: Date.new(current_year, 6, 21), season: :summer, icon: "sun", label: "Summer" },
        { date: Date.new(current_year, 9, 22), season: :fall, icon: "leaf", label: "Fall" },
        { date: Date.new(current_year, 12, 21), season: :winter, icon: "snowflake", label: "Winter" }
      ]

      seasons.each do |s|
        if s[:date].between?(start_date, end_date)
          boundaries << s
        end
      end

      current_year += 1
    end

    boundaries
  end

  def prepare_year_grid_data
    return unless @stays.any?

    # Determine year range
    min_year = @stays.minimum(:check_in).year
    max_year = @stays.maximum(:check_out).year
    @years_in_range = (min_year..max_year).to_a

    # Build lookup hash for stays by date
    @stays_by_date = {}
    @stays.each do |stay|
      (stay.check_in...stay.check_out).each do |date|
        @stays_by_date[date] = stay
      end
    end

    # Build lookup hash for gaps by date
    @gaps_by_date = {}
    @gaps.each do |gap|
      (gap[:start_date]...gap[:end_date]).each do |date|
        @gaps_by_date[date] = gap
      end
    end
  end

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
