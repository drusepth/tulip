class TransitRoutesController < ApplicationController
  before_action :set_stay

  def index
    @routes = @stay.transit_routes
    @routes = @routes.by_type(params[:route_type]) if params[:route_type].present?

    render json: @routes.map { |route|
      {
        id: route.id,
        name: route.name,
        route_type: route.route_type,
        color: route.color,
        geometry: route.geometry_coordinates
      }
    }
  end

  def fetch
    route_type = params[:route_type]

    unless TransitRoute::ROUTE_TYPES.include?(route_type)
      return render json: { error: 'Invalid route type' }, status: :bad_request
    end

    # Check if we already have cached routes for this stay and type
    existing_routes = @stay.transit_routes.by_type(route_type)

    if existing_routes.exists?
      return render json: format_routes(existing_routes)
    end

    # Fetch from Overpass API if stay has coordinates
    if @stay.latitude.present? && @stay.longitude.present?
      begin
        routes_data = OverpassService.fetch_transit_routes(
          lat: @stay.latitude.to_f,
          lng: @stay.longitude.to_f,
          route_type: route_type
        )
      rescue OverpassService::RateLimitedError
        return render json: { error: 'Rate limited by upstream API. Please retry later.' }, status: :too_many_requests
      end

      # Cache the results
      routes_data.each do |route_data|
        @stay.transit_routes.find_or_create_by(osm_id: route_data[:osm_id]) do |route|
          route.assign_attributes(
            name: route_data[:name],
            route_type: route_type,
            color: route_data[:color],
            geometry: route_data[:geometry].to_json
          )
        end
      end

      render json: format_routes(@stay.transit_routes.by_type(route_type).reload)
    else
      render json: []
    end
  end

  private

  def set_stay
    @stay = find_accessible_stay(params[:stay_id] || params[:id])
  end

  def format_routes(routes)
    routes.map do |route|
      {
        id: route.id,
        name: route.name,
        route_type: route.route_type,
        color: route.color,
        geometry: route.geometry_coordinates
      }
    end
  end
end
