require "test_helper"

class PostTripRatingNotificationJobTest < ActiveJob::TestCase
  setup do
    @user_one = users(:one)
    @user_two = users(:two)
    @stay = stays(:one)

    # Stub FCM push notification calls
    stub_request(:post, /fcm\.googleapis\.com/).to_return(
      status: 200,
      body: { name: "projects/test/messages/123" }.to_json,
      headers: { "Content-Type" => "application/json" }
    )
  end

  test "creates trip_ended notifications for stays that ended yesterday" do
    # Set the stay's check_out to yesterday
    @stay.update_columns(check_out: Date.current - 1.day, check_in: Date.current - 5.days, status: "past")

    assert_difference "Notification.where(notification_type: 'trip_ended').count", 2 do
      PostTripRatingNotificationJob.perform_now
    end

    # Owner should get a notification
    owner_notification = @user_one.notifications.where(notification_type: "trip_ended").last
    assert_not_nil owner_notification
    assert_equal @stay, owner_notification.notifiable
    assert_includes owner_notification.message, @stay.title

    # Collaborator (user_two has an accepted collaboration on stay :one) should get a notification
    collaborator_notification = @user_two.notifications.where(notification_type: "trip_ended").last
    assert_not_nil collaborator_notification
    assert_equal @stay, collaborator_notification.notifiable
  end

  test "notification has correct target path to highlights screen" do
    @stay.update_columns(check_out: Date.current - 1.day, check_in: Date.current - 5.days, status: "past")

    PostTripRatingNotificationJob.perform_now

    notification = @user_one.notifications.where(notification_type: "trip_ended").last
    assert_equal stay_highlights_path(@stay), notification.target_path
  end

  test "does not create duplicate notifications if job runs twice" do
    @stay.update_columns(check_out: Date.current - 1.day, check_in: Date.current - 5.days, status: "past")

    PostTripRatingNotificationJob.perform_now

    assert_no_difference "Notification.where(notification_type: 'trip_ended').count" do
      PostTripRatingNotificationJob.perform_now
    end
  end

  test "does not create notifications for stays that ended two days ago" do
    @stay.update_columns(check_out: Date.current - 2.days, check_in: Date.current - 7.days, status: "past")

    assert_no_difference "Notification.count" do
      PostTripRatingNotificationJob.perform_now
    end
  end

  test "does not create notifications for stays ending today" do
    @stay.update_columns(check_out: Date.current, check_in: Date.current - 5.days, status: "current")

    assert_no_difference "Notification.count" do
      PostTripRatingNotificationJob.perform_now
    end
  end

  test "notification data includes stay info" do
    @stay.update_columns(check_out: Date.current - 1.day, check_in: Date.current - 5.days, status: "past")

    PostTripRatingNotificationJob.perform_now

    notification = @user_one.notifications.where(notification_type: "trip_ended").last
    assert_equal @stay.id, notification.data["stay_id"]
    assert_equal @stay.title, notification.data["stay_title"]
    assert_equal @stay.city, notification.data["city"]
  end

  private

  def stay_highlights_path(stay)
    Rails.application.routes.url_helpers.stay_highlights_path(stay)
  end
end
