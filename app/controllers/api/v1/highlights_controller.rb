module Api
  module V1
    class HighlightsController < BaseController
      before_action :set_stay

      def show
        completed_items = @stay.bucket_list_items
                               .completed
                               .includes(:ratings, ratings: :user)
                               .ordered

        categories = completed_items.map(&:category).compact.uniq.sort
        items_by_category = completed_items.group_by { |item| item.category || "other" }

        # Compute aggregate stats
        participants = all_stay_participants
        trip_average = compute_trip_average(completed_items)
        user_stats = compute_user_rating_stats(completed_items, current_user)
        collaborator_stats = participants.reject { |u| u == current_user }.map do |user|
          {
            user: user_json(user),
            stats: compute_user_rating_stats(completed_items, user)
          }
        end.select { |cs| cs[:stats].present? }

        render json: {
          stay: stay_summary_json(@stay),
          stats: {
            trip_average: trip_average,
            user_stats: user_stats,
            collaborator_stats: collaborator_stats
          },
          categories: categories,
          items_by_category: items_by_category.transform_values do |items|
            items.map { |item| item_json(item) }
          end
        }
      end

      private

      def set_stay
        @stay = find_accessible_stay(params[:stay_id])
      end

      def all_stay_participants
        ([ @stay.owner ] + @stay.collaborators.to_a).uniq
      end

      def compute_user_rating_stats(items, user)
        user_ratings = items.flat_map(&:ratings).select { |r| r.user_id == user.id }
        return nil if user_ratings.empty?

        {
          average: (user_ratings.sum(&:rating).to_f / user_ratings.count).round(1),
          count: user_ratings.count,
          distribution: (1..5).map { |star| user_ratings.count { |r| r.rating == star } }
        }
      end

      def compute_trip_average(items)
        all_ratings = items.flat_map(&:ratings)
        return nil if all_ratings.empty?

        (all_ratings.sum(&:rating).to_f / all_ratings.count).round(1)
      end

      def stay_summary_json(stay)
        {
          id: stay.id,
          title: stay.title,
          city: stay.city,
          country: stay.country,
          check_in: stay.check_in,
          check_out: stay.check_out
        }
      end

      def user_json(user)
        {
          id: user.id,
          name: user.name || user.email.split("@").first,
          avatar_url: user.respond_to?(:avatar_url) ? user.avatar_url : nil
        }
      end

      def item_json(item)
        {
          id: item.id,
          title: item.title,
          address: item.address,
          category: item.category || "other",
          completed_at: item.completed_at,
          average_rating: item.average_rating,
          ratings: item.ratings.map do |rating|
            {
              user_id: rating.user_id,
              user_name: rating.user.name || rating.user.email.split("@").first,
              avatar_url: rating.user.respond_to?(:avatar_url) ? rating.user.avatar_url : nil,
              rating: rating.rating
            }
          end
        }
      end
    end
  end
end
