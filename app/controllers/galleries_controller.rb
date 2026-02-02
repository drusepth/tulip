class GalleriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stay

  def show
    fetch_images_if_needed
    @images = @stay.destination_images || []
  end

  def refresh
    @stay.update(destination_images: [], images_fetched_at: nil)
    fetch_images_if_needed
    redirect_to stay_gallery_path(@stay), notice: "Gallery refreshed with new images."
  end

  private

  def set_stay
    @stay = current_user.accessible_stays.find(params[:stay_id])
  end

  def fetch_images_if_needed
    return if @stay.images_fetched_at.present? && @stay.images_fetched_at > 30.days.ago
    return unless @stay.city.present? || @stay.country.present?

    images = UnsplashService.fetch_images(
      city: @stay.city.presence || @stay.title,
      country: @stay.country
    )
    @stay.update(destination_images: images, images_fetched_at: Time.current)
  end
end
