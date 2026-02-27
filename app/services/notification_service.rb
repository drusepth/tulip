class NotificationService
  class << self
    def comment_created(comment)
      return if comment.rating_comment?

      stay = comment.stay
      # Only notify for stay comments (places are public, no owner/collaborator model)
      return unless stay

      actor = comment.user

      # Notify the stay owner and collaborators (except the commenter)
      recipients = recipients_for_stay(stay, exclude: actor)

      recipients.each do |recipient|
        Notification.create!(
          user: recipient,
          notification_type: "comment_on_stay",
          notifiable: comment,
          data: {
            actor_id: actor.id,
            actor_name: actor.name,
            stay_id: stay.id,
            stay_title: stay.title,
            comment_preview: comment.body&.truncate(100)
          }
        )
      end
    end

    def reply_created(reply)
      return if reply.rating_comment?
      return unless reply.parent.present?

      parent_author = reply.parent.user
      actor = reply.user

      # Don't notify if replying to own comment
      return if parent_author == actor

      stay = reply.stay
      notification_data = {
        actor_id: actor.id,
        actor_name: actor.name,
        reply_preview: reply.body&.truncate(100)
      }

      # Include stay context if this is a stay comment
      if stay
        notification_data[:stay_id] = stay.id
        notification_data[:stay_title] = stay.title
      end

      Notification.create!(
        user: parent_author,
        notification_type: "reply_to_comment",
        notifiable: reply,
        data: notification_data
      )
    end

    def bucket_list_item_completed(item, completed_by:)
      stay = item.stay
      actor = completed_by

      # Notify the stay owner and collaborators (except who completed it)
      recipients = recipients_for_stay(stay, exclude: actor)

      recipients.each do |recipient|
        Notification.create!(
          user: recipient,
          notification_type: "bucket_list_completed",
          notifiable: item,
          data: {
            actor_id: actor.id,
            actor_name: actor.name,
            stay_id: stay.id,
            stay_title: stay.title,
            item_title: item.title
          }
        )
      end
    end

    def bucket_list_item_rated(rating)
      item = rating.bucket_list_item
      stay = item.stay
      actor = rating.user

      # Notify the stay owner and collaborators (except who rated it)
      recipients = recipients_for_stay(stay, exclude: actor)

      recipients.each do |recipient|
        Notification.create!(
          user: recipient,
          notification_type: "bucket_list_rated",
          notifiable: rating,
          data: {
            actor_id: actor.id,
            actor_name: actor.name,
            stay_id: stay.id,
            stay_title: stay.title,
            item_title: item.title,
            rating: rating.rating
          }
        )
      end
    end

    def collaboration_accepted(collaboration)
      stay = collaboration.stay
      actor = collaboration.user

      # Notify the stay owner
      owner = stay.owner
      return if owner == actor

      Notification.create!(
        user: owner,
        notification_type: "collaboration_accepted",
        notifiable: collaboration,
        data: {
          actor_id: actor.id,
          actor_name: actor.name,
          stay_id: stay.id,
          stay_title: stay.title
        }
      )
    end

    def collaboration_invited(collaboration)
      invited_user = collaboration.invited_user
      return unless invited_user.present?

      stay = collaboration.stay
      inviter = stay.owner
      return if invited_user == inviter

      Notification.create!(
        user: invited_user,
        notification_type: "collaboration_invited",
        notifiable: collaboration,
        data: {
          actor_id: inviter.id,
          inviter_name: inviter.name,
          stay_id: stay.id,
          stay_title: stay.title,
          invite_token: collaboration.invite_token
        }
      )
    end

    def trip_ended(stay)
      # Notify ALL participants (owner + collaborators) to rate places
      recipients = all_participants_for_stay(stay)

      notifications = recipients.map do |recipient|
        Notification.create!(
          user: recipient,
          notification_type: "trip_ended",
          notifiable: stay,
          data: {
            stay_id: stay.id,
            stay_title: stay.title,
            city: stay.city
          }
        )
      end

      # Send push notifications to mobile devices
      notifications.each do |notification|
        PushNotificationService.send_to_user(
          notification.user,
          title: "How was #{stay.city}?",
          body: notification.message,
          data: {
            notification_id: notification.id.to_s,
            notification_type: "trip_ended",
            stay_id: stay.id.to_s,
            target_path: "/stays/#{stay.id}/highlights"
          }
        )
      end

      notifications
    end

    private

    def recipients_for_stay(stay, exclude:)
      recipients = [ stay.owner ]
      recipients += stay.collaborators.to_a
      recipients.uniq.reject { |u| u == exclude }
    end

    def all_participants_for_stay(stay)
      recipients = [ stay.owner ]
      recipients += stay.collaborators.to_a
      recipients.uniq
    end
  end
end
