module Api
  module V1
    class BaseController < ActionController::API
      include ActionController::MimeResponds
      before_action :authenticate_devise_api_token!

      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity

      private

      def current_user
        current_devise_api_user
      end

      def not_found
        render json: { error: "Not found" }, status: :not_found
      end

      def unprocessable_entity(exception)
        render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
      end

      def find_accessible_stay(id)
        current_user.accessible_stays.find(id)
      end

      def require_stay_edit_permission
        @stay = find_accessible_stay(params[:stay_id] || params[:id])
        unless @stay.editable_by?(current_user)
          render json: { error: "Not authorized to edit this stay" }, status: :forbidden
        end
      end
    end
  end
end
