class TenantRightsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @states = tenant_rights_data.values.sort_by { |s| s["name"] }
  end

  def show
    @state = tenant_rights_data.values.find { |s| s["slug"] == params[:state_slug] }

    if @state.nil?
      redirect_to tenant_rights_path, alert: "State not found"
    end
  end

  private

  def tenant_rights_data
    @tenant_rights_data ||= YAML.load_file(Rails.root.join("config/data/tenant_rights.yml"))
  end
end
