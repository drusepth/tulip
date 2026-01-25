class PoisController < ApplicationController
  before_action :set_stay

  def index
    @pois = @stay.pois
    @pois = @pois.by_category(params[:category]) if params[:category].present?

    render json: @pois.map { |poi|
      {
        id: poi.id,
        name: poi.name,
        category: poi.category,
        latitude: poi.latitude,
        longitude: poi.longitude,
        distance_meters: poi.distance_meters,
        address: poi.address,
        opening_hours: poi.opening_hours,
        favorite: poi.favorite
      }
    }
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
            opening_hours: poi_data[:opening_hours]
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

  private

  def set_stay
    @stay = Stay.find(params[:stay_id] || params[:id])
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
        favorite: poi.favorite
      }
    end
  end
end
