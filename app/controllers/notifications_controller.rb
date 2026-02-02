class NotificationsController < ApplicationController
  def index
    @notifications = current_user.notifications.recent.by_date

    respond_to do |format|
      format.html { render partial: "notifications/list", locals: { notifications: @notifications } }
      format.turbo_stream
    end
  end

  def mark_read
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_as_read!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path }
    end
  end

  def mark_all_read
    current_user.mark_all_notifications_read!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path }
    end
  end
end
