module Api
  module V1
    class StaysController < BaseController
      before_action :set_stay, only: [ :show, :update, :destroy, :weather, :gallery ]
      before_action :require_stay_edit_permission, only: [ :update ]
      before_action :require_stay_owner, only: [ :destroy ]

      DEFAULT_POI_RADIUS_KM = 5.0

      def index
        @stays = current_user.accessible_stays.chronological
        render json: @stays.map { |stay| stay_json(stay) }
      end

      def show
        render json: stay_json(@stay, full: true)
      end

      def create
        @stay = current_user.stays.build(stay_params)

        if @stay.save
          render json: stay_json(@stay, full: true), status: :created
        else
          render json: { errors: @stay.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @stay.update(stay_params)
          render json: stay_json(@stay, full: true)
        else
          render json: { errors: @stay.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @stay.destroy
        head :no_content
      end

      def weather
        if @stay.latitude.present? && @stay.longitude.present?
          existing_weather = @stay.expected_weather
          if @stay.weather_stale? || existing_weather&.dig(:daily_data).blank?
            @stay.fetch_weather!
          end
        end

        weather = @stay.expected_weather
        daily_data = weather&.dig(:daily_data) || []

        render json: {
          stay_id: @stay.id,
          weather: weather,
          daily_data: daily_data
        }
      end

      def gallery
        return render json: { places: [] } unless @stay.latitude.present? && @stay.longitude.present?

        page = [ params[:page].to_i, 1 ].max
        per_page = 20

        gallery_categories = (Place::BROWSABLE_CATEGORIES - %w[stations bus_stops])

        places = Place.within_radius(
          lat: @stay.latitude,
          lng: @stay.longitude,
          radius_km: DEFAULT_POI_RADIUS_KM
        ).where(category: gallery_categories)
         .order(Arel.sql("CASE WHEN foursquare_photo_url IS NOT NULL THEN 0 ELSE 1 END"))

        favorite_place_ids = @stay.pois.favorites.pluck(:place_id).to_set
        bucket_list_place_ids = @stay.bucket_list_items.where.not(place_id: nil).pluck(:place_id).to_set

        places_with_distance = places.map do |place|
          {
            id: place.id,
            name: place.name,
            category: place.category,
            address: place.address,
            latitude: place.latitude,
            longitude: place.longitude,
            distance_meters: place.distance_from(@stay.latitude, @stay.longitude),
            favorite: favorite_place_ids.include?(place.id),
            in_bucket_list: bucket_list_place_ids.include?(place.id),
            foursquare_photo_url: place.foursquare_photo_url,
            foursquare_rating: place.foursquare_rating,
            foursquare_price: place.foursquare_price
          }
        end.sort_by { |p| p[:distance_meters] || Float::INFINITY }

        total_count = places_with_distance.size
        total_pages = (total_count.to_f / per_page).ceil
        start_index = (page - 1) * per_page
        page_places = places_with_distance[start_index, per_page] || []

        render json: {
          places: page_places,
          page: page,
          total_pages: total_pages,
          total_count: total_count,
          has_more: page < total_pages
        }
      end

      private

      def set_stay
        @stay = find_accessible_stay(params[:id])
      end

      def require_stay_owner
        unless @stay.owner?(current_user)
          render json: { error: "Only the owner can perform this action" }, status: :forbidden
        end
      end

      def stay_params
        params.permit(
          :title, :stay_type, :booking_url, :image_url,
          :address, :city, :state, :country, :latitude, :longitude,
          :check_in, :check_out, :price_total_dollars, :currency, :notes,
          :booked
        )
      end

      def stay_json(stay, full: false)
        data = {
          id: stay.id,
          title: stay.title,
          stay_type: stay.stay_type,
          booking_url: stay.booking_url,
          image_url: stay.image_url,
          address: stay.address,
          city: stay.city,
          state: stay.state,
          country: stay.country,
          latitude: stay.latitude,
          longitude: stay.longitude,
          check_in: stay.check_in,
          check_out: stay.check_out,
          price_total_cents: stay.price_total_cents,
          currency: stay.currency,
          status: stay.status,
          booked: stay.booked,
          is_wishlist: stay.wishlist?,
          duration_days: stay.duration_days,
          days_until_check_in: stay.days_until_check_in,
          is_owner: stay.owner?(current_user),
          can_edit: stay.editable_by?(current_user)
        }

        if full
          data.merge!(
            notes: stay.notes,
            weather: stay.expected_weather,
            bucket_list_count: stay.bucket_list_items.count,
            bucket_list_completed_count: stay.bucket_list_items.completed.count,
            collaborator_count: stay.collaborator_count
          )
        end

        data
      end
    end
  end
end
