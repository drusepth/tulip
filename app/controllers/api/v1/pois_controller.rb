module Api
  module V1
    class PoisController < BaseController
      before_action :set_stay

      def index
        @pois = @stay.pois.includes(:place)
        @pois = @pois.by_category(params[:category]) if params[:category].present?

        render json: format_pois(@pois)
      end

      def fetch
        category = params[:category]

        unless Place::CATEGORIES.include?(category)
          return render json: { error: "Invalid category" }, status: :bad_request
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
            return render json: { error: "Rate limited by upstream API. Please retry later." }, status: :too_many_requests
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

      def toggle_favorite
        place = Place.find(params[:place_id])

        # Find or create Poi for this stay+place combination
        @poi = @stay.pois.find_or_initialize_by(place: place)
        @poi.category = place.category if @poi.new_record?
        @poi.favorite = !@poi.favorite
        @poi.save!

        render json: { success: true, favorite: @poi.favorite, poi_id: @poi.id }
      end

      private

      def set_stay
        @stay = find_accessible_stay(params[:stay_id])
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
            description: place.description,
            foursquare_rating: place.foursquare_rating,
            foursquare_price: place.foursquare_price,
            foursquare_photo_url: place.foursquare_photo_url
          }
        end
      end
    end
  end
end
