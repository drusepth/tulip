module Api
  module V1
    class CommentsController < BaseController
      before_action :set_stay, only: [ :index, :create ]
      before_action :set_comment, only: [ :update, :destroy ]
      before_action :require_comment_author, only: [ :update, :destroy ]

      def index
        @comments = @stay.comments.where(bucket_list_item_rating_id: nil).includes(:user).order(:created_at)
        render json: @comments.map { |comment| comment_json(comment) }
      end

      def create
        @comment = @stay.comments.build(comment_params)
        @comment.user = current_user

        if @comment.save
          render json: comment_json(@comment), status: :created
        else
          render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @comment.update(comment_params)
          render json: comment_json(@comment)
        else
          render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @comment.destroy
        head :no_content
      end

      private

      def set_stay
        @stay = find_accessible_stay(params[:stay_id])
      end

      def set_comment
        @comment = Comment.joins(:commentable)
          .where(commentable_type: "Stay", commentable_id: current_user.accessible_stays.select(:id))
          .find(params[:id])
      end

      def require_comment_author
        unless @comment.editable_by?(current_user)
          render json: { error: "You can only edit your own comments" }, status: :forbidden
        end
      end

      def comment_params
        params.permit(:body, :parent_id)
      end

      def comment_json(comment)
        {
          id: comment.id,
          body: comment.body || "",
          parent_id: comment.parent_id,
          user_id: comment.user_id,
          user_name: comment.user&.name || "Unknown",
          user_email: comment.user&.email || "",
          editable: comment.editable_by?(current_user),
          created_at: comment.created_at,
          updated_at: comment.updated_at
        }
      end
    end
  end
end
