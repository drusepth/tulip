module Api
  module V1
    class TenantRightsController < ActionController::API
      def index
        states = tenant_rights_data.values.sort_by { |s| s["name"] }
        render json: states.map { |s| state_summary_json(s) }
      end

      def show
        state = tenant_rights_data.values.find { |s| s["slug"] == params[:state_slug] }

        if state
          render json: state_json(state)
        else
          render json: { error: "State not found" }, status: :not_found
        end
      end

      private

      def tenant_rights_data
        @tenant_rights_data ||= YAML.load_file(Rails.root.join("config/data/tenant_rights.yml"))
      end

      def state_summary_json(state)
        {
          name: state["name"],
          slug: state["slug"],
          summary: state["summary"],
          tenant_threshold_days: state["tenant_threshold_days"]
        }
      end

      def state_json(state)
        {
          name: state["name"],
          slug: state["slug"],
          summary: state["summary"],
          tenant_threshold_days: state["tenant_threshold_days"],
          sections: state["sections"]
        }
      end
    end
  end
end
