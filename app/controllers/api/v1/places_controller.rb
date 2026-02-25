module Api
  module V1
    class PlacesController < BaseController
      NEARBY_RADIUS_KM = 5.0

      def show
        @place = Place.find(params[:id])
        FoursquareService.enrich_place(@place)
        WikidataService.enrich_place(@place)

        render json: place_json(@place)
      end

      private

      def place_json(place)
        {
          id: place.id,
          name: place.name,
          category: place.category,
          address: place.address,
          latitude: place.latitude,
          longitude: place.longitude,
          opening_hours: place.opening_hours,
          website: place.website,
          phone: place.phone,
          cuisine: place.cuisine,
          outdoor_seating: place.outdoor_seating,
          internet_access: place.internet_access,
          air_conditioning: place.air_conditioning,
          takeaway: place.takeaway,
          brand: place.brand,
          description: place.description,
          foursquare_id: place.foursquare_id,
          foursquare_rating: place.foursquare_rating,
          foursquare_price: place.foursquare_price,
          foursquare_photo_url: place.foursquare_photo_url,
          foursquare_tips: place.foursquare_tip.present? ? [place.foursquare_tip] : nil,
          wikidata_id: place.wikidata_id,
          wikipedia_url: place.wikipedia_url,
          wikipedia_extract: place.wikipedia_extract,
          image_url: place.wikidata_image_url
        }
      end
    end
  end
end
