module Api
  module V1
    class CollaborationsController < BaseController
      before_action :set_stay
      before_action :require_stay_owner, only: [ :create, :destroy ]

      def index
        @collaborations = @stay.stay_collaborations.includes(:user).order(:created_at)

        render json: {
          pending: @collaborations.pending.map { |c| collaboration_json(c) },
          accepted: @collaborations.accepted.map { |c| collaboration_json(c) }
        }
      end

      def create
        @collaboration = @stay.stay_collaborations.build(
          role: safe_role,
          invited_email: params[:invited_email]&.strip&.downcase
        )

        if @collaboration.save
          render json: {
            collaboration: collaboration_json(@collaboration),
            invite_url: @collaboration.invite_url
          }, status: :created
        else
          render json: { errors: @collaboration.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @collaboration = @stay.stay_collaborations.find(params[:id])

        # Prevent removing the owner
        if @collaboration.role == "owner"
          return render json: { error: "Cannot remove the owner" }, status: :forbidden
        end

        @collaboration.destroy
        head :no_content
      end

      def leave
        # Check owner first - owners don't have collaboration records
        if @stay.owner?(current_user)
          return render json: { error: "Owners cannot leave their own stays" }, status: :forbidden
        end

        @collaboration = @stay.stay_collaborations.find_by(user: current_user)

        if @collaboration.nil?
          return render json: { error: "You are not a collaborator on this stay" }, status: :not_found
        end

        @collaboration.destroy
        head :no_content
      end

      private

      def set_stay
        @stay = find_accessible_stay(params[:stay_id])
      end

      def require_stay_owner
        unless @stay.owner?(current_user)
          render json: { error: "Only the owner can perform this action" }, status: :forbidden
        end
      end

      def safe_role
        allowed = StayCollaboration::ROLES.excluding("owner")
        allowed.include?(params[:role]) ? params[:role] : "editor"
      end

      def collaboration_json(collaboration)
        {
          id: collaboration.id,
          role: collaboration.role,
          invited_email: collaboration.invited_email,
          invite_accepted: collaboration.invite_accepted?,
          invite_token: collaboration.invite_token,
          user: collaboration.user ? {
            id: collaboration.user.id,
            name: collaboration.user.name,
            email: collaboration.user.email
          } : nil,
          created_at: collaboration.created_at
        }
      end
    end
  end
end
