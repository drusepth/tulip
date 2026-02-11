class BucketListItemsController < ApplicationController
  before_action :set_stay
  before_action :require_stay_edit_permission
  before_action :set_bucket_list_item, only: [:edit, :update, :destroy, :toggle]

  def create
    @bucket_list_item = @stay.bucket_list_items.build(bucket_list_item_params)
    @source_poi = @stay.pois.find_by(id: params[:source_poi_id]) if params[:source_poi_id].present?
    @compact = params[:compact].present?
    @explore = params[:explore].present?

    respond_to do |format|
      if @bucket_list_item.save
        format.turbo_stream
        format.html { redirect_to @stay, notice: "Bucket list item was successfully added." }
      else
        format.turbo_stream { render :create_error, status: :unprocessable_entity }
        format.html { redirect_to @stay, alert: @bucket_list_item.errors.full_messages.join(", ") }
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
