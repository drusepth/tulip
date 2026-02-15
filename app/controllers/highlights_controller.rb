class HighlightsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stay

  def show
    @completed_items = @stay.bucket_list_items
                            .completed
                            .includes(:ratings, ratings: :user)
                            .ordered

    @categories = @completed_items.map(&:category).uniq.sort
    @items_by_category = @completed_items.group_by(&:category)

    # Compute aggregate stats
    @participants = all_stay_participants
    @city_average = compute_city_average(@completed_items)
    @user_stats = compute_user_rating_stats(@completed_items, current_user)
    @collaborator_stats = @participants.reject { |u| u == current_user }.map do |user|
      { user: user, stats: compute_user_rating_stats(@completed_items, user) }
    end
  end

  private

  def set_stay
    @stay = current_user.accessible_stays.find(params[:stay_id])
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

  def compute_city_average(items)
    all_ratings = items.flat_map(&:ratings)
    return nil if all_ratings.empty?

    (all_ratings.sum(&:rating).to_f / all_ratings.count).round(1)
  end
end
