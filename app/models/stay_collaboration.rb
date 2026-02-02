class StayCollaboration < ApplicationRecord
  ROLES = %w[owner editor].freeze

  belongs_to :stay
  belongs_to :user, optional: true # Can be nil for pending invites

  validates :role, inclusion: { in: ROLES }
  validates :user_id, uniqueness: { scope: :stay_id, message: "is already a collaborator on this stay" }, if: :user_id?
  validates :invited_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  before_create :generate_invite_token, unless: :invite_accepted?
  after_create_commit :notify_invited_user, if: :should_notify_invited_user?
  after_update_commit :notify_on_acceptance, if: :saved_change_to_invite_accepted_at?

  scope :pending, -> { where(invite_accepted_at: nil) }
  scope :accepted, -> { where.not(invite_accepted_at: nil) }
  scope :editors, -> { where(role: 'editor') }
  scope :owners, -> { where(role: 'owner') }

  def pending?
    invite_accepted_at.nil?
  end

  def invite_accepted?
    invite_accepted_at.present?
  end

  def accept!(accepting_user)
    return false if invite_accepted?
    return false if accepting_user.nil?

    # Check if this user already has access to this stay
    if stay.accessible_by?(accepting_user)
      errors.add(:base, "You already have access to this stay")
      return false
    end

    update!(user: accepting_user, invite_accepted_at: Time.current)
    true
  end

  def invite_url
    return nil unless invite_token.present?
    Rails.application.routes.url_helpers.accept_invite_url(invite_token, host: default_url_host)
  end

  def invited_user
    return nil if invited_email.blank?
    @invited_user ||= User.find_by(email: invited_email.downcase)
  end

  private

  def should_notify_invited_user?
    invited_email.present? && invited_user.present?
  end

  def notify_invited_user
    NotificationService.collaboration_invited(self)
  end

  def notify_on_acceptance
    return unless invite_accepted_at.present?
    NotificationService.collaboration_accepted(self)
  end

  def generate_invite_token
    self.invite_token = SecureRandom.urlsafe_base64(32)
  end

  def default_url_host
    Rails.application.config.action_mailer.default_url_options&.fetch(:host, 'localhost:3000') || 'localhost:3000'
  end
end
