class PlaceCommentsController < ApplicationController
  before_action :set_place
  before_action :set_comment, only: [ :edit, :update, :destroy ]
  before_action :require_comment_author, only: [ :edit, :update, :destroy ]

  def create
    @comment = @place.comments.build(comment_params)
    @comment.user = current_user
    @commentable = @place

    respond_to do |format|
      if @comment.save
        format.turbo_stream { render "comments/create_for_place" }
        format.html { redirect_to place_path(@place), notice: "Comment was successfully added." }
      else
        format.turbo_stream { render "comments/create_error", status: :unprocessable_entity }
        format.html { redirect_to place_path(@place), alert: @comment.errors.full_messages.join(", ") }
      end
    end
  end

  def edit
    @commentable = @place

    respond_to do |format|
      format.turbo_stream { render "comments/edit" }
      format.html { redirect_to place_path(@place) }
    end
  end

  def update
    @commentable = @place

    respond_to do |format|
      if @comment.update(comment_params)
        format.turbo_stream { render "comments/update_for_place" }
        format.html { redirect_to place_path(@place), notice: "Comment was successfully updated." }
      else
        format.turbo_stream { render "comments/update_error", status: :unprocessable_entity }
        format.html { redirect_to place_path(@place), alert: @comment.errors.full_messages.join(", ") }
      end
    end
  end

  def destroy
    @comment.destroy
    @commentable = @place

    respond_to do |format|
      format.turbo_stream { render "comments/destroy_for_place" }
      format.html { redirect_to place_path(@place), notice: "Comment was removed." }
    end
  end

  private

  def set_place
    @place = Place.find(params[:place_id])
  end

  def set_comment
    @comment = @place.comments.find(params[:id])
  end

  def require_comment_author
    unless @comment.editable_by?(current_user)
      respond_to do |format|
        format.turbo_stream { head :forbidden }
        format.html { redirect_to place_path(@place), alert: "You can only edit your own comments" }
      end
    end
  end

  def comment_params
    params.require(:comment).permit(:body, :parent_id)
  end
end
