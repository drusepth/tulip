module Api
  module V1
    class DestinationsController < BaseController
      def index
        @destinations = FeaturedDestination.all

        render json: @destinations.map { |destination|
          {
            id: destination.id,
            city: destination.city,
            country: destination.country,
            description: destination.description,
            image_url: destination.image_url,
            latitude: destination.latitude,
            longitude: destination.longitude
          }
        }
      end
    end
  end
end
