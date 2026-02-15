class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def update_resource(resource, params)
    if requires_password?(params)
      super
    else
      resource.update(params.except(:current_password, :password, :password_confirmation))
    end
  end

  private

  def requires_password?(params)
    params[:password].present? || params[:email] != resource.email
  end
end
