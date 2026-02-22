module Api
  module V1
    class InvitesController < BaseController
      def accept
        @collaboration = StayCollaboration.find_by(invite_token: params[:token])

        if @collaboration.nil?
          return render json: { error: "Invalid or expired invite link" }, status: :not_found
        end

        @stay = @collaboration.stay

        if @collaboration.invite_accepted?
          if @collaboration.user == current_user
            return render json: {
              message: "You already have access to this stay",
              stay_id: @stay.id
            }
          else
            return render json: { error: "This invite has already been used" }, status: :gone
          end
        end

        if @collaboration.accept!(current_user)
          render json: {
            message: "You now have access to \"#{@stay.title}\"",
            stay_id: @stay.id,
            stay: {
              id: @stay.id,
              title: @stay.title,
              city: @stay.city,
              country: @stay.country
            }
          }
        else
          render json: { errors: @collaboration.errors.full_messages }, status: :unprocessable_entity
        end
      end
    end
  end
end
