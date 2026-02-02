class DashboardController < ApplicationController
  def index
    # If we just processed an invite, redirect to the stay
    return if redirect_if_pending_stay

    user_stays = current_user.accessible_stays

    # Update statuses for the user's stays (only those with dates)
    update_statuses!(user_stays.with_dates)

    # Alerts (only shown when action needed)
    @gaps = user_stays.find_gaps
    @booking_alert = booking_alert(user_stays)

    # Hero section: Current & Next
    @current_stay = current_stay(user_stays)
    @next_stay = user_stays.upcoming.first

    # Upcoming stays timeline (all upcoming, with images)
    @upcoming_stays = user_stays.upcoming

    # Wishlist: stays without dates (dream destinations)
    @wishlist_stays = user_stays.wishlist

    # Secondary: Stats & Recent
    @total_stays = user_stays.count
    @states_visited = user_stays.past.reorder(nil).distinct.pluck(:state).compact.count
    @recent_stays = user_stays.past.limit(5)
  end

  private

  def update_statuses!(stays)
    today = Date.current
    stays.where('check_out < ?', today).update_all(status: 'past')
    stays.where('check_in <= ? AND check_out >= ?', today, today).update_all(status: 'current')
    stays.where('check_in > ?', today).update_all(status: 'upcoming')
  end

  def current_stay(stays)
    today = Date.current
    stays.with_dates.find_by('check_in <= ? AND check_out >= ?', today, today)
  end

  def booking_alert(stays)
    next_unbooked = stays.upcoming.planned.first
    return nil unless next_unbooked

    days_until = next_unbooked.days_until_check_in
    threshold_days = Stay::BOOKING_ALERT_MONTHS_THRESHOLD * 30

    return nil if days_until > threshold_days

    {
      destination: next_unbooked,
      days_until_check_in: days_until,
      city: next_unbooked.city,
      state: next_unbooked.state
    }
  end
end
