class PoisController < ApplicationController
  before_action :set_stay, except: [:search]
  before_action :require_stay_edit_permission, only: [:update, :destroy]

  def index
    @pois = @stay.pois.includes(:place)
    @pois = @pois.by_category(params[:category]) if params[:category].present?

    render json: format_pois(@pois)
  end

  def fetch
    category = params[:category]

    unless Place::CATEGORIES.include?(category)
      return render json: { error: 'Invalid category' }, status: :bad_request
    end

    # Check if we already have cached POIs for this stay and category
    existing_pois = @stay.pois.by_category(category).includes(:place)

    if existing_pois.exists?
      return render json: format_pois(existing_pois)
    end

    # Fetch from Overpass API if stay has coordinates
    if @stay.latitude.present? && @stay.longitude.present?
      begin
        pois_data = OverpassService.fetch_pois(
          lat: @stay.latitude.to_f,
          lng: @stay.longitude.to_f,
          category: category
        )
      rescue OverpassService::RateLimitedError
        return render json: { error: 'Rate limited by upstream API. Please retry later.' }, status: :too_many_requests
      end

      # Cache the results
      pois_data.each do |poi_data|
        place = Place.find_or_create_from_overpass(poi_data, category: category)
        @stay.pois.find_or_create_by(place: place, category: category) do |poi|
          poi.distance_meters = poi_data[:distance_meters]
        end
      end

      render json: format_pois(@stay.pois.by_category(category).includes(:place).reload)
    else
      render json: []
    end
  end

  def update
    @poi = @stay.pois.find(params[:id])

    if @poi.update(poi_params)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "poi_favorite_#{@poi.id}",
            partial: "pois/favorite_button",
            locals: { poi: @poi, stay: @stay }
          )
        end
        format.json { render json: { success: true, poi: @poi } }
      end
    else
      respond_to do |format|
        format.turbo_stream { head :unprocessable_entity }
        format.json { render json: { errors: @poi.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @poi = @stay.pois.find(params[:id])
    @poi.destroy
    head :no_content
  end

  # Viewport-based POI search (not tied to a specific stay)
  def search
    lat = params[:lat].to_f
    lng = params[:lng].to_f
    category = params[:category]

    unless Place::CATEGORIES.include?(category)
      return render json: { error: 'Invalid category' }, status: :bad_request
    end

    if lat == 0 && lng == 0
      return render json: { error: 'Invalid coordinates' }, status: :bad_request
    end

    grid_key = ViewportPoi.grid_key_for(lat: lat, lng: lng, category: category)

    # Check if we have a fresh cache for this grid (works even for empty results)
    if SearchedGridCell.fresh_cache?(grid_key)
      return render json: format_viewport_pois(ViewportPoi.by_grid_key(grid_key).includes(:place))
    end

    # Cache miss or stale - fetch from Overpass API using grid center
    grid_center = ViewportPoi.grid_center_for(lat: lat, lng: lng)

    begin
      pois_data = OverpassService.fetch_pois(
        lat: grid_center[:lat],
        lng: grid_center[:lng],
        category: category
      )
    rescue OverpassService::RateLimitedError
      return render json: { error: 'Rate limited by upstream API. Please retry later.' }, status: :too_many_requests
    end

    # Mark grid as searched (even if empty!) - this fixes the bug where empty
    # grid cells were never cached and caused repeated API requests
    SearchedGridCell.mark_searched!(grid_key, category: category)

    # Clear any old POIs for this grid before caching new ones (for stale refresh)
    ViewportPoi.where(grid_key: grid_key).destroy_all

    # Cache the results
    pois_data.each do |poi_data|
      place = Place.find_or_create_from_overpass(poi_data, category: category)
      ViewportPoi.find_or_create_by(grid_key: grid_key, place: place) do |vpoi|
        vpoi.category = category
        vpoi.center_lat = grid_center[:lat]
        vpoi.center_lng = grid_center[:lng]
      end
    end

    render json: format_viewport_pois(ViewportPoi.by_grid_key(grid_key).includes(:place))
  end

  private

  def set_stay
    @stay = find_accessible_stay(params[:stay_id] || params[:id])
  end

  def poi_params
    params.require(:poi).permit(:favorite)
  end

  def format_pois(pois)
    pois.map do |poi|
      place = poi.place
      {
        id: poi.id,
        place_id: place.id,
        name: place.name,
        category: poi.category,
        latitude: place.latitude,
        longitude: place.longitude,
        distance_meters: poi.distance_meters,
        address: place.address,
        opening_hours: place.opening_hours,
        favorite: poi.favorite,
        website: place.website,
        phone: place.phone,
        cuisine: place.cuisine,
        outdoor_seating: place.outdoor_seating,
        internet_access: place.internet_access,
        air_conditioning: place.air_conditioning,
        takeaway: place.takeaway,
        brand: place.brand,
        description: place.description
      }
    end
  end

  def format_viewport_pois(pois)
    pois.map do |vpoi|
      place = vpoi.place
      {
        id: vpoi.id,
        place_id: place.id,
        name: place.name,
        category: vpoi.category,
        latitude: place.latitude,
        longitude: place.longitude,
        address: place.address,
        opening_hours: place.opening_hours,
        viewport_poi: true,
        website: place.website,
        phone: place.phone,
        cuisine: place.cuisine,
        outdoor_seating: place.outdoor_seating,
        internet_access: place.internet_access,
        air_conditioning: place.air_conditioning,
        takeaway: place.takeaway,
        brand: place.brand,
        description: place.description
      }
    end
  end
end
