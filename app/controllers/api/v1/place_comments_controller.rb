module Api
  module V1
    class PlaceCommentsController < BaseController
      before_action :set_place

      def index
        @comments = @place.comments.includes(:user).order(:created_at)
        render json: @comments.map { |comment| comment_json(comment) }
      end

      def create
        @comment = @place.comments.build(comment_params)
        @comment.user = current_user

        if @comment.save
          render json: comment_json(@comment), status: :created
        else
          render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_place
        @place = Place.find(params[:place_id])
      end

      def comment_params
        params.permit(:body, :parent_id)
      end

      def comment_json(comment)
        {
          id: comment.id,
          body: comment.body,
          parent_id: comment.parent_id,
          user_id: comment.user_id,
          user_name: comment.user.name,
          user_email: comment.user.email,
          editable: comment.editable_by?(current_user),
          created_at: comment.created_at,
          updated_at: comment.updated_at
        }
      end
    end
  end
end
