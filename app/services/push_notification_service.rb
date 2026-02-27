class PushNotificationService
  FCM_URL = "https://fcm.googleapis.com/v1/projects/%s/messages:send"

  class << self
    def send_to_user(user, title:, body:, data: {})
      tokens = user.device_tokens.active
      return if tokens.empty?

      tokens.find_each do |device_token|
        send_to_device(device_token, title: title, body: body, data: data)
      end
    end

    private

    def send_to_device(device_token, title:, body:, data: {})
      project_id = firebase_project_id
      return unless project_id.present?

      access_token = firebase_access_token
      return unless access_token.present?

      url = FCM_URL % project_id

      message = {
        message: {
          token: device_token.token,
          notification: {
            title: title,
            body: body
          },
          data: data.transform_values(&:to_s)
        }
      }

      # Add platform-specific config
      case device_token.platform
      when "android"
        message[:message][:android] = {
          priority: "high",
          notification: { channel_id: "trip_reminders" }
        }
      when "ios"
        message[:message][:apns] = {
          payload: {
            aps: {
              sound: "default",
              badge: 1
            }
          }
        }
      end

      response = HTTParty.post(
        url,
        headers: {
          "Authorization" => "Bearer #{access_token}",
          "Content-Type" => "application/json"
        },
        body: message.to_json
      )

      # Deactivate token if FCM says it's invalid
      if response.code == 404 || (response.code == 400 && response.body.include?("UNREGISTERED"))
        device_token.update!(active: false)
      end

      Rails.logger.info("[PushNotification] Sent to #{device_token.platform} device for user #{device_token.user_id}: #{response.code}")
    rescue StandardError => e
      Rails.logger.error("[PushNotification] Failed to send to device #{device_token.id}: #{e.message}")
    end

    def firebase_project_id
      Rails.application.credentials.dig(:firebase, :project_id)
    end

    def firebase_access_token
      # Use Google Auth library if available, otherwise fall back to server key
      # For FCM HTTP v1 API, we need an OAuth2 access token from a service account
      service_account = Rails.application.credentials.dig(:firebase, :service_account)
      return nil unless service_account.present?

      # Use the google-auth gem to get an access token from the service account JSON
      if defined?(Google::Auth::ServiceAccountCredentials)
        credentials = Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: StringIO.new(service_account.to_json),
          scope: "https://www.googleapis.com/auth/firebase.messaging"
        )
        credentials.fetch_access_token!
        credentials.access_token
      else
        # Fallback: use the legacy FCM server key if v1 API credentials aren't configured
        Rails.application.credentials.dig(:firebase, :server_key)
      end
    end
  end
end
