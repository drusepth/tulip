class CommentsController < ApplicationController
  before_action :set_stay
  before_action :set_comment, only: [:edit, :update, :destroy]
  before_action :require_comment_author, only: [:edit, :update, :destroy]

  def create
    @comment = @stay.comments.build(comment_params)
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        format.turbo_stream
        format.html { redirect_to @stay, notice: "Comment was successfully added." }
      else
        format.turbo_stream { render :create_error, status: :unprocessable_entity }
        format.html { redirect_to @stay, alert: @comment.errors.full_messages.join(", ") }
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
      if @comment.update(comment_params)
        format.turbo_stream
        format.html { redirect_to @stay, notice: "Comment was successfully updated." }
      else
        format.turbo_stream { render :update_error, status: :unprocessable_entity }
        format.html { redirect_to @stay, alert: @comment.errors.full_messages.join(", ") }
      end
    end
  end

  def destroy
    @comment.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @stay, notice: "Comment was removed." }
    end
  end

  private

  def set_stay
    @stay = find_accessible_stay(params[:stay_id])
  end

  def set_comment
    @comment = @stay.comments.find(params[:id])
  end

  def require_comment_author
    unless @comment.editable_by?(current_user)
      respond_to do |format|
        format.turbo_stream { head :forbidden }
        format.html { redirect_to @stay, alert: "You can only edit your own comments" }
      end
    end
  end

  def comment_params
    params.require(:comment).permit(:body, :parent_id)
  end
end
