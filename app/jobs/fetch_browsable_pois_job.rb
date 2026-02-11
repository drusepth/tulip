class FetchBrowsablePoisJob < ApplicationJob
  queue_as :default

  def perform(stay_id)
    stay = Stay.find_by(id: stay_id)
    return unless stay&.latitude.present? && stay&.longitude.present?

    cached = stay.pois_cached_categories || []
    categories_to_fetch = Place::BROWSABLE_CATEGORIES - cached

    return if categories_to_fetch.empty?

    categories_to_fetch.each do |category|
      pois_data = OverpassService.fetch_pois(
        lat: stay.latitude.to_f,
        lng: stay.longitude.to_f,
        category: category
      )

      pois_data.each do |poi_data|
        place = Place.find_or_create_from_overpass(poi_data, category: category)
        stay.pois.find_or_create_by(place: place, category: category) do |poi|
          poi.distance_meters = poi_data[:distance_meters]
        end
      end
    end

    stay.update(pois_cached_categories: cached | categories_to_fetch)
  end
end
