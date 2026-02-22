module Api
  module V1
    class MapController < BaseController
      def stays
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
            is_shared: !stay.owner?(current_user)
          }
        }
      end

      def pois_search
        lat = params[:lat].to_f
        lng = params[:lng].to_f
        category = params[:category]

        unless Place::CATEGORIES.include?(category)
          return render json: { error: "Invalid category" }, status: :bad_request
        end

        if lat == 0 && lng == 0
          return render json: { error: "Invalid coordinates" }, status: :bad_request
        end

        grid_key = ViewportPoi.grid_key_for(lat: lat, lng: lng, category: category)

        # Check if we have a fresh cache for this grid
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
          return render json: { error: "Rate limited by upstream API. Please retry later." }, status: :too_many_requests
        end

        # Mark grid as searched
        SearchedGridCell.mark_searched!(grid_key, category: category)

        # Clear any old POIs for this grid before caching new ones
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

      def bucket_list_items
        @items = BucketListItem.includes(:stay)
                               .where(stay: current_user.accessible_stays)
                               .with_location

        render json: @items.map { |item|
          {
            id: item.id,
            title: item.title,
            address: item.address,
            latitude: item.latitude,
            longitude: item.longitude,
            completed: item.completed?,
            category: item.category,
            stay_id: item.stay_id,
            stay_title: item.stay.title
          }
        }
      end

      private

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
  end
end
