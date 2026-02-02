class FetchBrowsablePoisJob < ApplicationJob
  queue_as :default

  def perform(stay_id)
    stay = Stay.find_by(id: stay_id)
    return unless stay&.latitude.present? && stay&.longitude.present?

    cached = stay.pois_cached_categories || []
    categories_to_fetch = Poi::BROWSABLE_CATEGORIES - cached

    return if categories_to_fetch.empty?

    categories_to_fetch.each do |category|
      pois_data = OverpassService.fetch_pois(
        lat: stay.latitude.to_f,
        lng: stay.longitude.to_f,
        category: category
      )

      pois_data.each do |poi_data|
        stay.pois.find_or_create_by(osm_id: poi_data[:osm_id]) do |poi|
          poi.assign_attributes(poi_attributes_from(poi_data, category))
        end
      end
    end

    stay.update(pois_cached_categories: cached | categories_to_fetch)
  end

  private

  def poi_attributes_from(poi_data, category)
    {
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
    }
  end
end
