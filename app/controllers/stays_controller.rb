require 'ostruct'

class StaysController < ApplicationController
  before_action :set_stay, only: [:show, :edit, :update, :destroy, :weather, :edit_notes, :update_notes, :place_search]
  before_action :require_stay_edit_permission, only: [:edit, :update, :edit_notes, :update_notes]
  before_action :require_stay_owner, only: [:destroy]

  def index
    @stays = current_user.accessible_stays.chronological
  end

  DEFAULT_POI_RADIUS_KM = 5.0

  def show
    bucket_list_titles = @stay.bucket_list_items.pluck(:title).map { |t| t&.downcase }.to_set

    # Query Place directly with spatial filter to get ALL places within radius
    # This includes places discovered via map panning (ViewportPois) not just stay-linked Pois
    if @stay.latitude.present? && @stay.longitude.present?
      browsable_categories = Place::BROWSABLE_CATEGORIES - %w[stations bus_stops]
      places = Place.within_radius(
        lat: @stay.latitude,
        lng: @stay.longitude,
        radius_km: DEFAULT_POI_RADIUS_KM
      ).where(category: browsable_categories)

      # Build place data with distance and group by category
      places_with_distance = places.map do |place|
        next if bucket_list_titles.include?(place.name&.downcase)
        OpenStruct.new(
          place: place,
          poi: @stay.pois.find_by(place_id: place.id), # for backward compat, may be nil
          name: place.name,
          cuisine: place.cuisine,
          category: place.category,
          distance_meters: place.distance_from(@stay.latitude, @stay.longitude),
          address: place.address
        )
      end.compact

      @pois_by_category = places_with_distance.group_by(&:category)
    else
      @pois_by_category = {}
    end

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
      title: params[:title],
      check_in: params[:check_in],
      check_out: params[:check_out],
      city: params[:city],
      country: params[:country].presence || "USA"
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

  def edit_notes
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def update_notes
    respond_to do |format|
      if @stay.update(notes: params[:stay][:notes])
        format.turbo_stream
        format.html { redirect_to @stay, notice: "Notes updated." }
      else
        format.turbo_stream { render :edit_notes, status: :unprocessable_entity }
        format.html { redirect_to @stay, alert: "Could not update notes." }
      end
    end
  end

  def place_search
    query = params[:q].to_s.strip
    places = if @stay.latitude.present? && @stay.longitude.present? && query.present?
      Place.search_nearby(lat: @stay.latitude, lng: @stay.longitude, query: query, radius_km: DEFAULT_POI_RADIUS_KM)
    else
      Place.none
    end

    render json: places.map { |place|
      {
        id: place.id,
        name: place.name,
        category: place.category,
        address: place.address
      }
    }
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
        wishlist: stay.wishlist?,
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
