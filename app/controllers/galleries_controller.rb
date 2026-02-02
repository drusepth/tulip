class GalleriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stay

  def show
    fetch_venues_if_needed
    @venues = @stay.destination_images || []
  end

  def refresh
    @stay.update(destination_images: [], images_fetched_at: nil)
    fetch_venues_if_needed
    redirect_to stay_gallery_path(@stay), notice: "Gallery refreshed with new venues."
  end

  def add_to_bucket_list
    venue = find_venue_by_fsq_id(params[:fsq_id])

    if venue.blank?
      redirect_to stay_gallery_path(@stay), alert: "Venue not found."
      return
    end

    category = map_foursquare_category_to_bucket_list(venue['category'])

    @bucket_list_item = @stay.bucket_list_items.build(
      title: venue['name'],
      address: venue['address'],
      category: category,
      latitude: venue['lat'],
      longitude: venue['lng'],
      user: current_user
    )

    if @bucket_list_item.save
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("venue-card-#{venue['fsq_id']}", partial: "galleries/venue_card", locals: { venue: venue, added: true }) }
        format.html { redirect_to stay_gallery_path(@stay), notice: "\"#{venue['name']}\" added to your bucket list!" }
      end
    else
      redirect_to stay_gallery_path(@stay), alert: @bucket_list_item.errors.full_messages.join(", ")
    end
  end

  private

  def set_stay
    @stay = current_user.accessible_stays.find(params[:stay_id])
  end

  def fetch_venues_if_needed
    return if @stay.images_fetched_at.present? && @stay.images_fetched_at > 30.days.ago
    return unless @stay.latitude.present? && @stay.longitude.present?

    venues = FoursquareGalleryService.fetch_venues_with_photos(
      lat: @stay.latitude,
      lng: @stay.longitude
    )
    @stay.update(destination_images: venues, images_fetched_at: Time.current)
  end

  def find_venue_by_fsq_id(fsq_id)
    return nil if fsq_id.blank?
    (@stay.destination_images || []).find { |v| v['fsq_id'] == fsq_id }
  end

  def map_foursquare_category_to_bucket_list(foursquare_category)
    return 'other' if foursquare_category.blank?

    category_lower = foursquare_category.downcase

    case category_lower
    when /restaurant|cafe|coffee|bakery|bar|pub|brewery|winery|food|dining|pizza|sushi|taco|burger/
      'restaurant'
    when /museum|gallery|theater|theatre|cinema|concert|music|art|exhibit/
      'activity'
    when /park|garden|beach|trail|hike|nature|lake|mountain|forest|reserve/
      'nature'
    when /shop|store|market|mall|boutique|bookstore|retail/
      'shopping'
    when /club|nightclub|lounge|disco/
      'nightlife'
    when /monument|landmark|historic|memorial|castle|palace|tower|bridge|statue/
      'landmark'
    when /tour|experience|spa|wellness|adventure|class|workshop/
      'experience'
    else
      'other'
    end
  end
end
