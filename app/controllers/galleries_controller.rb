class GalleriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stay

  GALLERY_CATEGORIES = (Poi::BROWSABLE_CATEGORIES - %w[stations bus_stops]).freeze

  def show
    fetch_pois_if_needed
    ensure_browsable_pois_cached
    @pois = @stay.pois.where(category: GALLERY_CATEGORIES)
                      .order(Arel.sql("CASE WHEN foursquare_photo_url IS NOT NULL THEN 0 ELSE 1 END"), :distance_meters)
    @categories = GALLERY_CATEGORIES
  end

  def add_to_bucket_list
    # Support both poi_id (OSM/all POIs) and fsq_id (legacy Foursquare)
    poi = if params[:poi_id].present?
      @stay.pois.find_by(id: params[:poi_id])
    else
      @stay.pois.find_by(foursquare_id: params[:fsq_id])
    end

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
        format.turbo_stream { render turbo_stream: turbo_stream.replace("venue-card-#{poi.id}", partial: "galleries/venue_card", locals: { poi: poi, added: true }) }
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

  def ensure_browsable_pois_cached
    # POIs are fetched asynchronously via FetchBrowsablePoisJob
    # triggered by Stay callbacks. If not yet cached, enqueue the job.
    return unless @stay.latitude.present? && @stay.longitude.present?

    cached = @stay.pois_cached_categories || []
    missing = GALLERY_CATEGORIES - cached

    if missing.any?
      FetchBrowsablePoisJob.perform_later(@stay.id)
    end
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
