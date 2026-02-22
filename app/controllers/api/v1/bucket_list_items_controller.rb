module Api
  module V1
    class BucketListItemsController < BaseController
      before_action :set_stay, only: [ :index, :create ]
      before_action :set_bucket_list_item, only: [ :update, :destroy, :toggle, :rate ]

      def index
        @items = @stay.bucket_list_items.includes(:place)
        render json: @items.map { |item| bucket_list_item_json(item) }
      end

      def create
        @bucket_list_item = @stay.bucket_list_items.build(bucket_list_item_params)
        @bucket_list_item.user = current_user

        # Support place_id for linking to Place
        if params[:place_id].present?
          @bucket_list_item.place = Place.find_by(id: params[:place_id])
        end

        if @bucket_list_item.save
          render json: bucket_list_item_json(@bucket_list_item), status: :created
        else
          render json: { errors: @bucket_list_item.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @bucket_list_item.update(bucket_list_item_params)
          render json: bucket_list_item_json(@bucket_list_item)
        else
          render json: { errors: @bucket_list_item.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @bucket_list_item.destroy
        head :no_content
      end

      def toggle
        @bucket_list_item.toggle_completed!

        if @bucket_list_item.completed?
          NotificationService.bucket_list_item_completed(@bucket_list_item, completed_by: current_user)
        end

        render json: bucket_list_item_json(@bucket_list_item)
      end

      def rate
        rating_value = params[:rating].to_i

        if rating_value < 1 || rating_value > 5
          return render json: { error: "Rating must be between 1 and 5" }, status: :bad_request
        end

        rating = @bucket_list_item.bucket_list_item_ratings.find_or_initialize_by(user: current_user)
        rating.rating = rating_value

        if rating.save
          render json: {
            bucket_list_item_id: @bucket_list_item.id,
            user_rating: rating_value,
            average_rating: @bucket_list_item.average_rating
          }
        else
          render json: { errors: rating.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_stay
        @stay = find_accessible_stay(params[:stay_id])
      end

      def set_bucket_list_item
        @bucket_list_item = BucketListItem.joins(:stay)
          .where(stay: current_user.accessible_stays)
          .find(params[:id])
      end

      def bucket_list_item_params
        params.permit(:title, :category, :notes, :address, :latitude, :longitude)
      end

      def bucket_list_item_json(item)
        {
          id: item.id,
          title: item.title,
          category: item.category,
          notes: item.notes,
          address: item.address,
          latitude: item.latitude,
          longitude: item.longitude,
          completed: item.completed?,
          completed_at: item.completed_at,
          stay_id: item.stay_id,
          place_id: item.place_id,
          average_rating: item.average_rating,
          user_rating: item.bucket_list_item_ratings.find_by(user: current_user)&.rating,
          created_at: item.created_at,
          updated_at: item.updated_at
        }
      end
    end
  end
end
