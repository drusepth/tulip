class StaysController < ApplicationController
  before_action :set_stay, only: [:show, :edit, :update, :destroy, :weather]
  before_action :require_stay_edit_permission, only: [:edit, :update]
  before_action :require_stay_owner, only: [:destroy]

  def index
    @stays = current_user.accessible_stays.chronological
  end

  def show
    @pois_by_category = @stay.pois.where.not(category: ['bus_stops', 'stations']).group_by(&:category)

    # Fetch weather data if stale and stay has coordinates
    if @stay.latitude.present? && @stay.longitude.present? && @stay.weather_stale?
      @stay.fetch_weather!
    end
    @weather = @stay.expected_weather

    # For collaboration display
    @is_owner = @stay.owner?(current_user)
    @can_edit = @stay.editable_by?(current_user)
  end

  def weather
    # Fetch weather data if stale or missing daily_data (for backward compatibility)
    if @stay.latitude.present? && @stay.longitude.present?
      existing_weather = @stay.expected_weather
      if @stay.weather_stale? || existing_weather&.dig(:daily_data).blank?
        @stay.fetch_weather!
      end
    end
    @weather = @stay.expected_weather
    @daily_data = @weather&.dig(:daily_data) || []
  end

  def new
    @stay = current_user.stays.new(
      check_in: params[:check_in],
      check_out: params[:check_out]
    )
    @overlapping_stays = []
  end

  def edit
    @overlapping_stays = @stay.overlapping_stays(current_user.accessible_stays)
  end

  def create
    @stay = current_user.stays.build(stay_params)
    @overlapping_stays = @stay.overlapping_stays(current_user.accessible_stays)

    if @stay.save
      redirect_to @stay, notice: "Stay was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @stay.update(stay_params)
      redirect_to @stay, notice: "Stay was successfully updated."
    else
      @overlapping_stays = @stay.overlapping_stays(current_user.accessible_stays)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @stay.destroy
    redirect_to stays_url, notice: "Stay was successfully deleted."
  end

  def map_data
    @stays = current_user.accessible_stays.where.not(latitude: nil, longitude: nil)
    render json: @stays.map { |stay|
      {
        id: stay.id,
        title: stay.title,
        latitude: stay.latitude,
        longitude: stay.longitude,
        status: stay.status,
        booked: stay.booked,
        check_in: stay.check_in,
        check_out: stay.check_out,
        city: stay.city,
        country: stay.country,
        image_url: stay.image_url,
        duration_days: stay.duration_days,
        url: stay_path(stay),
        is_shared: !stay.owner?(current_user)
      }
    }
  end

  private

  def set_stay
    @stay = find_accessible_stay(params[:id])
  end

  def stay_params
    params.require(:stay).permit(
      :title, :stay_type, :booking_url, :image_url,
      :address, :city, :state, :country, :latitude, :longitude,
      :check_in, :check_out, :price_total_dollars, :currency, :notes,
      :booked
    )
  end
end
