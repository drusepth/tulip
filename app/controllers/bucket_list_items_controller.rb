class BucketListItemsController < ApplicationController
  before_action :set_stay, except: [:map_index]
  before_action :require_stay_edit_permission, except: [:map_index]
  before_action :set_bucket_list_item, only: [:edit, :update, :destroy, :toggle]

  def map_index
    @items = BucketListItem.includes(:stay)
                           .where(stay: current_user.accessible_stays)
                           .with_location

    render json: @items.map { |item|
      {
        id: item.id,
        title: item.title,
        address: item.address,
        latitude: item.latitude,
        longitude: item.longitude,
        completed: item.completed?,
        category: item.category,
        stay_id: item.stay_id,
        stay_title: item.stay.title
      }
    }
  end

  def create
    @bucket_list_item = @stay.bucket_list_items.build(bucket_list_item_params)
    @bucket_list_item.user = current_user
    @source_poi = @stay.pois.find_by(id: params[:source_poi_id]) if params[:source_poi_id].present?
    @bucket_list_item.place = @source_poi.place if @source_poi&.place
    @compact = params[:compact].present?

    respond_to do |format|
      if @bucket_list_item.save
        format.turbo_stream
        format.html { redirect_to @stay, notice: "Bucket list item was successfully added." }
        format.json { render json: { success: true, item: @bucket_list_item }, status: :created }
      else
        format.turbo_stream { render :create_error, status: :unprocessable_entity }
        format.html { redirect_to @stay, alert: @bucket_list_item.errors.full_messages.join(", ") }
        format.json { render json: { success: false, errors: @bucket_list_item.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def edit
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @stay }
    end
  end

  def update
    respond_to do |format|
      if @bucket_list_item.update(bucket_list_item_params)
        format.turbo_stream
        format.html { redirect_to @stay, notice: "Bucket list item was successfully updated." }
      else
        format.turbo_stream { render :update_error, status: :unprocessable_entity }
        format.html { redirect_to @stay, alert: @bucket_list_item.errors.full_messages.join(", ") }
      end
    end
  end

  def destroy
    @bucket_list_item.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @stay, notice: "Bucket list item was removed." }
    end
  end

  def toggle
    @bucket_list_item.toggle_completed!

    if @bucket_list_item.completed?
      NotificationService.bucket_list_item_completed(@bucket_list_item, completed_by: current_user)
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @stay }
    end
  end

  private

  def set_stay
    @stay = find_accessible_stay(params[:stay_id])
  end

  def set_bucket_list_item
    @bucket_list_item = @stay.bucket_list_items.find(params[:id])
  end

  def bucket_list_item_params
    params.require(:bucket_list_item).permit(:title, :category, :notes, :address)
  end
end
