module Api
  module V1
    class DeviceTokensController < BaseController
      def create
        device_token = current_user.device_tokens.find_or_initialize_by(
          token: params[:token]
        )
        device_token.platform = params[:platform]
        device_token.active = true
        device_token.save!

        render json: { id: device_token.id, token: device_token.token, platform: device_token.platform }, status: :ok
      end

      def destroy
        device_token = current_user.device_tokens.find_by(token: params[:token])
        device_token&.update!(active: false)

        render json: { success: true }, status: :ok
      end
    end
  end
end
