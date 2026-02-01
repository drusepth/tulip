class PoisController < ApplicationController
  before_action :set_stay, except: [:search]
  before_action :require_stay_edit_permission, only: [:update, :destroy]

  def browse
    @current_category = params[:category].presence || 'coffee'
    @current_category = 'coffee' unless Poi::BROWSABLE_CATEGORIES.include?(@current_category)

    ensure_pois_cached(@current_category)
    @pois = @stay.pois.by_category(@current_category).nearest

    # Enrich POIs with Foursquare data (lazy, cached per-POI)
    @pois.each { |poi| FoursquareService.enrich_poi(poi) }

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("poi_tabs", partial: "pois/tabs", locals: { stay: @stay, current_category: @current_category }),
          turbo_stream.replace("poi_list", partial: "pois/list", locals: { pois: @pois, category: @current_category, stay: @stay })
        ]
      end
    end
  end

  def index
    @pois = @stay.pois
    @pois = @pois.by_category(params[:category]) if params[:category].present?

    render json: format_pois(@pois)
  end

  def fetch
    category = params[:category]

    unless Poi::CATEGORIES.include?(category)
      return render json: { error: 'Invalid category' }, status: :bad_request
    end

    # Check if we already have cached POIs for this stay and category
    existing_pois = @stay.pois.by_category(category)

    if existing_pois.exists?
      return render json: format_pois(existing_pois)
    end

    # Fetch from Overpass API if stay has coordinates
    if @stay.latitude.present? && @stay.longitude.present?
      pois_data = OverpassService.fetch_pois(
        lat: @stay.latitude.to_f,
        lng: @stay.longitude.to_f,
        category: category
      )

      # Cache the results
      pois_data.each do |poi_data|
        @stay.pois.find_or_create_by(osm_id: poi_data[:osm_id]) do |poi|
          poi.assign_attributes(
            name: poi_data[:name],
            category: category,
            latitude: poi_data[:latitude],
            longitude: poi_data[:longitude],
            distance_meters: poi_data[:distance_meters],
            address: poi_data[:address],
            opening_hours: poi_data[:opening_hours],
            website: poi_data[:website],
            phone: poi_data[:phone],
            cuisine: poi_data[:cuisine],
            outdoor_seating: poi_data[:outdoor_seating],
            internet_access: poi_data[:internet_access],
            air_conditioning: poi_data[:air_conditioning],
            takeaway: poi_data[:takeaway],
            brand: poi_data[:brand],
            description: poi_data[:description]
          )
        end
      end

      render json: format_pois(@stay.pois.by_category(category).reload)
    else
      render json: []
    end
  end

  def update
    @poi = @stay.pois.find(params[:id])

    if @poi.update(poi_params)
      render json: { success: true, poi: @poi }
    else
      render json: { errors: @poi.errors.full_messages }, status: :unprocessable_entity
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

    unless Poi::CATEGORIES.include?(category)
      return render json: { error: 'Invalid category' }, status: :bad_request
    end

    if lat == 0 && lng == 0
      return render json: { error: 'Invalid coordinates' }, status: :bad_request
    end

    grid_key = ViewportPoi.grid_key_for(lat: lat, lng: lng, category: category)

    # Check cache first
    if ViewportPoi.cached_for_grid?(grid_key)
      return render json: format_viewport_pois(ViewportPoi.by_grid_key(grid_key))
    end

    # Cache miss - fetch from Overpass API using grid center
    grid_center = ViewportPoi.grid_center_for(lat: lat, lng: lng)

    pois_data = OverpassService.fetch_pois(
      lat: grid_center[:lat],
      lng: grid_center[:lng],
      category: category
    )

    # Cache the results
    pois_data.each do |poi_data|
      ViewportPoi.find_or_create_by(grid_key: grid_key, osm_id: poi_data[:osm_id]) do |poi|
        poi.assign_attributes(
          name: poi_data[:name],
          category: category,
          latitude: poi_data[:latitude],
          longitude: poi_data[:longitude],
          address: poi_data[:address],
          opening_hours: poi_data[:opening_hours],
          center_lat: grid_center[:lat],
          center_lng: grid_center[:lng],
          website: poi_data[:website],
          phone: poi_data[:phone],
          cuisine: poi_data[:cuisine],
          outdoor_seating: poi_data[:outdoor_seating],
          internet_access: poi_data[:internet_access],
          air_conditioning: poi_data[:air_conditioning],
          takeaway: poi_data[:takeaway],
          brand: poi_data[:brand],
          description: poi_data[:description]
        )
      end
    end

    render json: format_viewport_pois(ViewportPoi.by_grid_key(grid_key))
  end

  private

  def set_stay
    @stay = find_accessible_stay(params[:stay_id] || params[:id])
  end

  def ensure_pois_cached(category)
    return if @stay.pois.by_category(category).exists?
    return unless @stay.latitude.present? && @stay.longitude.present?

    pois_data = OverpassService.fetch_pois(
      lat: @stay.latitude.to_f,
      lng: @stay.longitude.to_f,
      category: category
    )

    pois_data.each do |poi_data|
      @stay.pois.find_or_create_by(osm_id: poi_data[:osm_id]) do |poi|
        poi.assign_attributes(
          name: poi_data[:name],
          category: category,
          latitude: poi_data[:latitude],
          longitude: poi_data[:longitude],
          distance_meters: poi_data[:distance_meters],
          address: poi_data[:address],
          opening_hours: poi_data[:opening_hours],
          website: poi_data[:website],
          phone: poi_data[:phone],
          cuisine: poi_data[:cuisine],
          outdoor_seating: poi_data[:outdoor_seating],
          internet_access: poi_data[:internet_access],
          air_conditioning: poi_data[:air_conditioning],
          takeaway: poi_data[:takeaway],
          brand: poi_data[:brand],
          description: poi_data[:description]
        )
      end
    end
  end

  def poi_params
    params.require(:poi).permit(:favorite)
  end

  def format_pois(pois)
    pois.map do |poi|
      {
        id: poi.id,
        name: poi.name,
        category: poi.category,
        latitude: poi.latitude,
        longitude: poi.longitude,
        distance_meters: poi.distance_meters,
        address: poi.address,
        opening_hours: poi.opening_hours,
        favorite: poi.favorite,
        website: poi.website,
        phone: poi.phone,
        cuisine: poi.cuisine,
        outdoor_seating: poi.outdoor_seating,
        internet_access: poi.internet_access,
        air_conditioning: poi.air_conditioning,
        takeaway: poi.takeaway,
        brand: poi.brand,
        description: poi.description
      }
    end
  end

  def format_viewport_pois(pois)
    pois.map do |poi|
      {
        id: poi.id,
        name: poi.name,
        category: poi.category,
        latitude: poi.latitude,
        longitude: poi.longitude,
        address: poi.address,
        opening_hours: poi.opening_hours,
        viewport_poi: true,
        website: poi.website,
        phone: poi.phone,
        cuisine: poi.cuisine,
        outdoor_seating: poi.outdoor_seating,
        internet_access: poi.internet_access,
        air_conditioning: poi.air_conditioning,
        takeaway: poi.takeaway,
        brand: poi.brand,
        description: poi.description
      }
    end
  end
end
