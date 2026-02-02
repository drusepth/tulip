class GalleriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stay

  def show
    fetch_pois_if_needed
    @pois = @stay.pois.with_photos.order(:distance_meters)
    @categories = @pois.map(&:category).uniq.sort
  end

  def refresh
    # Clear existing Foursquare data from POIs and refetch
    @stay.pois.with_photos.update_all(
      foursquare_id: nil,
      foursquare_rating: nil,
      foursquare_price: nil,
      foursquare_photo_url: nil,
      foursquare_fetched_at: nil
    )
    @stay.pois.from_foursquare.destroy_all
    @stay.update(images_fetched_at: nil)
    fetch_pois_if_needed
    redirect_to stay_gallery_path(@stay), notice: "Gallery refreshed with new venues."
  end

  def add_to_bucket_list
    poi = @stay.pois.find_by(foursquare_id: params[:fsq_id])

    if poi.blank?
      redirect_to stay_gallery_path(@stay), alert: "Venue not found."
      return
    end

    category = map_poi_category_to_bucket_list(poi.category)

    @bucket_list_item = @stay.bucket_list_items.build(
      title: poi.name,
      address: poi.address,
      category: category,
      latitude: poi.latitude,
      longitude: poi.longitude,
      user: current_user
    )

    if @bucket_list_item.save
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("venue-card-#{poi.foursquare_id}", partial: "galleries/venue_card", locals: { poi: poi, added: true }) }
        format.html { redirect_to stay_gallery_path(@stay), notice: "\"#{poi.name}\" added to your bucket list!" }
      end
    else
      redirect_to stay_gallery_path(@stay), alert: @bucket_list_item.errors.full_messages.join(", ")
    end
  end

  private

  def set_stay
    @stay = current_user.accessible_stays.find(params[:stay_id])
  end

  def fetch_pois_if_needed
    return if @stay.images_fetched_at.present? && @stay.images_fetched_at > 30.days.ago
    return unless @stay.latitude.present? && @stay.longitude.present?

    FoursquareGalleryService.fetch_and_save_pois(stay: @stay)
    @stay.update(images_fetched_at: Time.current)
  end

  def map_poi_category_to_bucket_list(poi_category)
    case poi_category
    when 'food', 'coffee'
      'restaurant'
    when 'parks'
      'nature'
    when 'grocery'
      'shopping'
    when 'gym', 'coworking', 'library'
      'activity'
    when 'stations', 'bus_stops'
      'other'
    else
      'other'
    end
  end
end
