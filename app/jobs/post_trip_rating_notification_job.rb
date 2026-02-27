class PostTripRatingNotificationJob < ApplicationJob
  queue_as :default

  def perform
    # Find stays that ended yesterday (check_out was yesterday)
    yesterday = Date.current - 1.day
    ended_stays = Stay.where(check_out: yesterday)

    ended_stays.find_each do |stay|
      # Skip if we already sent trip_ended notifications for this stay
      next if Notification.where(
        notification_type: "trip_ended",
        notifiable: stay
      ).exists?

      NotificationService.trip_ended(stay)
    end
  end
end
