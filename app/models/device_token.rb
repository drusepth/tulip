class DeviceToken < ApplicationRecord
  PLATFORMS = %w[ios android].freeze

  belongs_to :user

  validates :token, presence: true, uniqueness: { scope: :user_id }
  validates :platform, presence: true, inclusion: { in: PLATFORMS }

  scope :active, -> { where(active: true) }
end
