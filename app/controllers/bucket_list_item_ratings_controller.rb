class BucketListItemRatingsController < ApplicationController
  before_action :set_stay
  before_action :set_bucket_list_item
  before_action :require_stay_access

  def create
    @rating = @bucket_list_item.ratings.find_or_initialize_by(user: current_user)
    @rating.rating = params[:rating].to_i

    respond_to do |format|
      if @rating.save
        format.turbo_stream
        format.html { redirect_to @stay, notice: "Rating saved." }
      else
        format.turbo_stream { render :create_error, status: :unprocessable_entity }
        format.html { redirect_to @stay, alert: @rating.errors.full_messages.join(", ") }
      end
    end
  end

  def destroy
    @rating = @bucket_list_item.ratings.find_by(user: current_user)
    @rating&.destroy

    respond_to do |format|
      format.turbo_stream { render :create }
      format.html { redirect_to @stay, notice: "Rating removed." }
    end
  end

  private

  def set_stay
    @stay = current_user.accessible_stays.find(params[:stay_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Stay not found or you don't have access"
  end

  def set_bucket_list_item
    @bucket_list_item = @stay.bucket_list_items.find(params[:bucket_list_item_id])
  end

  def require_stay_access
    unless @stay.accessible_by?(current_user)
      redirect_to root_path, alert: "You don't have access to this stay"
    end
  end
end
