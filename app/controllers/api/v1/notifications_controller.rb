module Api
  module V1
    class NotificationsController < BaseController
      def index
        @notifications = current_user.notifications.recent.by_date

        render json: @notifications.map { |notification| notification_json(notification) }
      end

      def read
        @notification = current_user.notifications.find(params[:id])
        @notification.mark_as_read!

        render json: notification_json(@notification)
      end

      def mark_all_read
        current_user.mark_all_notifications_read!

        render json: { success: true, unread_count: 0 }
      end

      private

      def notification_json(notification)
        {
          id: notification.id,
          notification_type: notification.notification_type,
          message: notification.message,
          icon_name: notification.icon_name,
          ring_color: notification.ring_color,
          target_path: notification.target_path,
          read: notification.read?,
          created_at: notification.created_at
        }
      end
    end
  end
end
