class StayCollaborationsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:accept]
  before_action :set_stay, except: [:accept]
  before_action :require_stay_owner, except: [:accept, :leave]

  def index
    @collaborations = @stay.stay_collaborations.includes(:user).order(:created_at)
    @pending_invites = @collaborations.pending
    @accepted_collaborations = @collaborations.accepted
  end

  def create
    @collaboration = @stay.stay_collaborations.build(
      role: collaboration_params[:role] || 'editor'
    )

    if @collaboration.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to stay_collaborations_path(@stay), notice: "Invite link created! Share it with your collaborator." }
        format.json { render json: { invite_url: @collaboration.invite_url } }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :create_error, status: :unprocessable_entity }
        format.html { redirect_to stay_collaborations_path(@stay), alert: @collaboration.errors.full_messages.join(", ") }
        format.json { render json: { errors: @collaboration.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @collaboration = @stay.stay_collaborations.find(params[:id])

    # Prevent removing the owner
    if @collaboration.role == 'owner'
      redirect_to stay_collaborations_path(@stay), alert: "Cannot remove the owner"
      return
    end

    @collaboration.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to stay_collaborations_path(@stay), notice: "Collaborator removed" }
    end
  end

  # Allow a collaborator to remove themselves from a stay
  def leave
    # Check owner first - owners don't have collaboration records
    if @stay.owner?(current_user)
      redirect_to @stay, alert: "Owners cannot leave their own stays. Transfer ownership or delete the stay instead."
      return
    end

    @collaboration = @stay.stay_collaborations.find_by(user: current_user)

    if @collaboration.nil?
      redirect_to @stay, alert: "You are not a collaborator on this stay"
      return
    end

    @collaboration.destroy
    redirect_to root_path, notice: "You have left the stay \"#{@stay.title}\""
  end

  # Accept an invite via magic link - no auth required to view
  def accept
    @collaboration = StayCollaboration.find_by(invite_token: params[:token])

    if @collaboration.nil?
      redirect_to root_path, alert: "Invalid or expired invite link"
      return
    end

    @stay = @collaboration.stay

    if @collaboration.invite_accepted?
      if user_signed_in? && @collaboration.user == current_user
        redirect_to @stay, notice: "You already have access to this stay"
      else
        redirect_to root_path, alert: "This invite has already been used"
      end
      return
    end

    if user_signed_in?
      if @collaboration.accept!(current_user)
        redirect_to @stay, notice: "You now have access to \"#{@stay.title}\"!"
      else
        redirect_to root_path, alert: @collaboration.errors.full_messages.join(", ")
      end
    else
      # Store token in session and redirect to sign in
      session[:pending_invite_token] = params[:token]
      redirect_to new_user_session_path, notice: "Sign in or create an account to accept this invitation"
    end
  end

  private

  def set_stay
    @stay = find_accessible_stay(params[:stay_id])
  end

  def collaboration_params
    params.permit(:role)
  end
end
