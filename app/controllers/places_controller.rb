class PlacesController < ApplicationController
  NEARBY_RADIUS_KM = 5.0

  def show
    @place = Place.find(params[:id])
    FoursquareService.enrich_place(@place)
    WikidataService.enrich_place(@place)

    # Find a stay context if the user arrived from a stay
    if params[:stay_id].present?
      @stay = current_user.accessible_stays.find_by(id: params[:stay_id])
      @poi = @stay&.pois&.find_by(place: @place) if @stay
    end

    # Prev/next navigation within the same category (only when viewing from a stay)
    if @stay && @poi
      siblings = @stay.pois.by_category(@place.category).nearest.includes(:place).to_a
      current_index = siblings.index { |p| p.id == @poi.id }
      if current_index
        @prev_place = siblings[current_index - 1]&.place if current_index > 0
        @next_place = siblings[current_index + 1]&.place
      end
    end
  end

  def place_search
    @place = Place.find(params[:id])
    query = params[:q].to_s.strip
    places = if @place.latitude.present? && @place.longitude.present? && query.present?
      Place.search_nearby(lat: @place.latitude, lng: @place.longitude, query: query, radius_km: NEARBY_RADIUS_KM, exclude_id: @place.id)
    else
      Place.none
    end

    render json: places.map { |p|
      {
        id: p.id,
        name: p.name,
        category: p.category,
        address: p.address
      }
    }
  end
end
