module Api
  module V1
    class UsersController < BaseController
      def show
        render json: user_json(current_user)
      end

      def update
        if current_user.update(user_params)
          render json: user_json(current_user)
        else
          render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.permit(:display_name, :email)
      end

      def user_json(user)
        {
          id: user.id,
          email: user.email,
          display_name: user.display_name,
          name: user.name,
          created_at: user.created_at,
          unread_notifications_count: user.unread_notifications_count
        }
      end
    end
  end
end
