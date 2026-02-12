require 'ostruct'

class GalleriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stay

  GALLERY_CATEGORIES = (Place::BROWSABLE_CATEGORIES - %w[stations bus_stops]).freeze

  DEFAULT_RADIUS_KM = 5.0
  PER_PAGE = 20

  def show
    fetch_pois_if_needed
    ensure_browsable_pois_cached

    return unless @stay.latitude.present? && @stay.longitude.present?

    @page = [ params[:page].to_i, 1 ].max
    all_places = fetch_sorted_places

    @total_count = all_places.size
    @total_pages = (all_places.size.to_f / PER_PAGE).ceil

    # For turbo_stream requests, return only the current page
    # For HTML requests, return all pages up to and including the current page
    if turbo_stream_request?
      start_index = (@page - 1) * PER_PAGE
      @places_with_distance = all_places[start_index, PER_PAGE] || []
    else
      end_index = @page * PER_PAGE
      @places_with_distance = all_places[0, end_index] || []
    end

    @has_more = @page < @total_pages
    @categories = GALLERY_CATEGORIES

    respond_to do |format|
      format.html
      format.turbo_stream { render partial: "galleries/page", formats: [ :turbo_stream ] }
    end
  end

  def add_to_bucket_list
    # Support place_id (new), poi_id (legacy), and fsq_id (Foursquare)
    place = if params[:place_id].present?
      Place.find_by(id: params[:place_id])
    elsif params[:poi_id].present?
      @stay.pois.includes(:place).find_by(id: params[:poi_id])&.place
    elsif params[:fsq_id].present?
      Place.find_by(foursquare_id: params[:fsq_id])
    end

    if place.blank?
      redirect_to stay_gallery_path(@stay), alert: "Venue not found."
      return
    end

    category = map_poi_category_to_bucket_list(place.category)

    @bucket_list_item = @stay.bucket_list_items.build(
      title: place.name,
      address: place.address,
      category: category,
      latitude: place.latitude,
      longitude: place.longitude,
      user: current_user
    )

    if @bucket_list_item.save
      # Calculate distance for the response
      distance_meters = place.distance_from(@stay.latitude, @stay.longitude)
      place_with_distance = OpenStruct.new(
        place: place,
        distance_meters: distance_meters,
        favorite: false
      )

      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("venue-card-#{place.id}", partial: "galleries/venue_card", locals: { place_data: place_with_distance, added: true }) }
        format.html { redirect_to stay_gallery_path(@stay), notice: "\"#{place.name}\" added to your bucket list!" }
      end
    else
      redirect_to stay_gallery_path(@stay), alert: @bucket_list_item.errors.full_messages.join(", ")
    end
  end

  private

  def turbo_stream_request?
    request.headers["Accept"]&.include?("text/vnd.turbo-stream.html")
  end

  def fetch_sorted_places
    # Query Place directly with spatial filter to get ALL places within radius
    # This includes places discovered via map panning (ViewportPois) not just stay-linked Pois
    places = Place.within_radius(
      lat: @stay.latitude,
      lng: @stay.longitude,
      radius_km: DEFAULT_RADIUS_KM
    ).where(category: GALLERY_CATEGORIES)
     .order(Arel.sql("CASE WHEN foursquare_photo_url IS NOT NULL THEN 0 ELSE 1 END"))

    # Load favorite status from existing Poi records (sparse - only favorites exist or were fetched)
    favorite_place_ids = @stay.pois.favorites.pluck(:place_id).to_set

    # Add distance and favorite status to each place, then sort by distance
    places.map do |place|
      OpenStruct.new(
        place: place,
        distance_meters: place.distance_from(@stay.latitude, @stay.longitude),
        favorite: favorite_place_ids.include?(place.id)
      )
    end.sort_by { |p| p.distance_meters || Float::INFINITY }
  end

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
