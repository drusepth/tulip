class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :process_pending_invite, if: :user_signed_in?
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [ :display_name ])
  end

  # Process any pending invite stored in session after user signs in
  def process_pending_invite
    return unless session[:pending_invite_token]

    token = session.delete(:pending_invite_token)
    collaboration = StayCollaboration.find_by(invite_token: token)

    return unless collaboration && collaboration.pending?

    if collaboration.accept!(current_user)
      flash[:notice] = "You've been added as a collaborator on \"#{collaboration.stay.title}\"!"
      # Store the stay to redirect to after the current request
      session[:redirect_to_stay_id] = collaboration.stay_id
    end
  end

  # Helper to redirect to a stay if we just processed an invite
  def redirect_if_pending_stay
    if session[:redirect_to_stay_id]
      stay_id = session.delete(:redirect_to_stay_id)
      redirect_to stay_path(stay_id) and return true
    end
    false
  end

  # Find a stay the current user can access (owned or collaborated)
  def find_accessible_stay(id)
    current_user.accessible_stays.find(id)
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Stay not found or you don't have access"
    nil
  end

  # Verify user can edit the stay
  def require_stay_edit_permission
    unless @stay&.editable_by?(current_user)
      redirect_to(@stay || root_path, alert: "You don't have permission to edit this stay")
      nil
    end
  end

  # Verify user is the stay owner
  def require_stay_owner
    unless @stay&.owner?(current_user)
      redirect_to(@stay || root_path, alert: "Only the owner can perform this action")
      nil
    end
  end
end
