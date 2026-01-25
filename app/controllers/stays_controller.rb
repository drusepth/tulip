class StaysController < ApplicationController
  before_action :set_stay, only: [:show, :edit, :update, :destroy]

  def index
    @stays = Stay.chronological
  end

  def show
    @pois_by_category = @stay.pois.group_by(&:category)
  end

  def new
    @stay = Stay.new(
      check_in: params[:check_in],
      check_out: params[:check_out]
    )
    @overlapping_stays = []
  end

  def edit
    @overlapping_stays = @stay.overlapping_stays
  end

  def create
    @stay = Stay.new(stay_params)
    @overlapping_stays = @stay.overlapping_stays

    if @stay.save
      redirect_to @stay, notice: "Stay was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @stay.update(stay_params)
      redirect_to @stay, notice: "Stay was successfully updated."
    else
      @overlapping_stays = @stay.overlapping_stays
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @stay.destroy
    redirect_to stays_url, notice: "Stay was successfully deleted."
  end

  def map_data
    @stays = Stay.where.not(latitude: nil, longitude: nil)
    render json: @stays.map { |stay|
      {
        id: stay.id,
        title: stay.title,
        latitude: stay.latitude,
        longitude: stay.longitude,
        status: stay.status,
        check_in: stay.check_in,
        check_out: stay.check_out,
        city: stay.city,
        country: stay.country,
        url: stay_path(stay)
      }
    }
  end

  private

  def set_stay
    @stay = Stay.find(params[:id])
  end

  def stay_params
    params.require(:stay).permit(
      :title, :stay_type, :booking_url, :image_url,
      :address, :city, :country, :latitude, :longitude,
      :check_in, :check_out, :price_total_cents, :currency, :notes
    )
  end
end
