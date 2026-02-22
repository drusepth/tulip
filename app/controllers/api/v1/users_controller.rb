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

      def update_password
        unless current_user.valid_password?(password_params[:current_password])
          render json: { error: "Current password is incorrect" }, status: :unprocessable_entity
          return
        end

        if current_user.update(password: password_params[:password], password_confirmation: password_params[:password_confirmation])
          render json: { message: "Password updated successfully" }
        else
          render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        unless current_user.valid_password?(params[:current_password])
          render json: { error: "Current password is incorrect" }, status: :unprocessable_entity
          return
        end

        current_user.destroy
        render json: { message: "Account deleted successfully" }
      end

      private

      def user_params
        params.permit(:display_name, :email)
      end

      def password_params
        params.permit(:current_password, :password, :password_confirmation)
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
