class Stay < ApplicationRecord
  STAY_TYPES = %w[airbnb hotel hostel friend other].freeze
  STATUSES = %w[upcoming current past].freeze
  CURRENCIES = %w[USD EUR GBP JPY AUD CAD CHF CNY INR MXN].freeze
  BOOKING_ALERT_MONTHS_THRESHOLD = 4

  serialize :pois_cached_categories, coder: YAML, type: Array, default: []

  belongs_to :user # The owner of the stay

  has_many :pois, dependent: :destroy
  has_many :transit_routes, dependent: :destroy
  has_many :bucket_list_items, dependent: :destroy
  has_many :stay_collaborations, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :collaborators, -> { where.not(stay_collaborations: { invite_accepted_at: nil }) },
           through: :stay_collaborations, source: :user

  # Check if a user can access this stay (owner or accepted collaborator)
  def accessible_by?(check_user)
    return false unless check_user
    user_id == check_user.id || stay_collaborations.accepted.exists?(user: check_user)
  end

  # Check if a user can edit this stay (owner or editor role)
  def editable_by?(check_user)
    return false unless check_user
    user_id == check_user.id || stay_collaborations.accepted.editors.exists?(user: check_user)
  end

  # Check if a user is the owner
  def owner?(check_user)
    return false unless check_user
    user_id == check_user.id
  end

  # Get the owner user
  def owner
    user
  end

  # Get accepted collaborators count
  def collaborator_count
    stay_collaborations.accepted.count
  end

  validates :title, presence: true
  validates :city, presence: true
  validates :stay_type, inclusion: { in: STAY_TYPES }, if: :booked?
  validates :status, inclusion: { in: STATUSES }
  validates :currency, inclusion: { in: CURRENCIES }
  # Dates are optional for "wishlist" trips, but required when booked
  validates :check_in, presence: true, if: :booked?
  validates :check_out, presence: true, if: :booked?
  validate :check_out_after_check_in
  validate :no_overlapping_stays, on: :create

  # Auto-fill title from destination if not provided
  before_validation :set_default_title

  geocoded_by :full_address
  after_validation :geocode, if: :should_geocode?

  before_save :update_status
  after_commit :enqueue_poi_fetch, on: [ :create, :update ], if: :should_fetch_pois?
  after_save :clear_cached_location_data, if: :location_changed?

  scope :with_dates, -> { where.not(check_in: nil).where.not(check_out: nil) }
  scope :wishlist, -> { where(check_in: nil).or(where(check_out: nil)) }
  scope :upcoming, -> { with_dates.where(status: "upcoming").order(:check_in) }
  scope :current, -> { with_dates.where(status: "current") }
  scope :past, -> { with_dates.where(status: "past").order(check_out: :desc) }
  scope :chronological, -> { with_dates.order(:check_in) }
  scope :booked, -> { where(booked: true) }
  scope :planned, -> { where(booked: false) }

  def full_address
    [ address, city, country ].compact.join(", ")
  end

  def duration_days
    return 0 unless check_in && check_out
    (check_out - check_in).to_i
  end

  def days_until_check_in
    return nil unless check_in
    (check_in - Date.current).to_i
  end

  def days_until_check_out
    return nil unless check_out
    (check_out - Date.current).to_i
  end

  def price_formatted
    return nil unless price_total_cents
    "#{currency} #{price_total_cents / 100.0}"
  end

  # Virtual attribute for entering price in dollars
  def price_total_dollars
    return nil unless price_total_cents
    price_total_cents / 100.0
  end

  def price_total_dollars=(dollars)
    self.price_total_cents = dollars.present? ? (dollars.to_f * 100).round : nil
  end

  # Find stays that overlap with this one within a given scope (typically user's accessible stays)
  # If no scope provided, defaults to same user's stays
  def overlapping_stays(scope = nil)
    base_scope = scope || user&.accessible_stays || Stay.none
    base_scope.where.not(id: id)
              .where("check_in < ? AND check_out > ?", check_out, check_in)
  end

  def self.current_stay
    today = Date.current
    find_by("check_in <= ? AND check_out >= ?", today, today)
  end

  def self.next_upcoming
    upcoming.first
  end

  def self.update_all_statuses!
    today = Date.current
    where("check_out < ?", today).update_all(status: "past")
    where("check_in <= ? AND check_out >= ?", today, today).update_all(status: "current")
    where("check_in > ?", today).update_all(status: "upcoming")
  end

  # Find gaps between stays. Works on any relation (e.g., current_user.stays.find_gaps)
  # Only considers stays with dates (excludes wishlist items)
  def self.find_gaps
    gaps = []
    ordered_stays = with_dates.chronological.to_a
    return gaps if ordered_stays.empty?

    # Track the furthest coverage date to handle overlapping stays
    max_check_out = ordered_stays.first.check_out

    ordered_stays[1..].each do |stay|
      if stay.check_in > max_check_out
        # There's a gap between coverage and this stay's check_in
        gaps << {
          type: :gap,
          start_date: max_check_out,
          end_date: stay.check_in,
          days: (stay.check_in - max_check_out).to_i
        }
      end
      # Extend coverage if this stay ends later
      max_check_out = [ max_check_out, stay.check_out ].max
    end
    gaps
  end

  # Returns booking alert info if there's an unbooked upcoming stay within the threshold
  # Returns nil if no action needed
  def self.booking_alert(months_threshold: BOOKING_ALERT_MONTHS_THRESHOLD)
    next_unbooked = upcoming.planned.first
    return nil unless next_unbooked

    days_until = next_unbooked.days_until_check_in
    threshold_days = months_threshold * 30

    return nil if days_until > threshold_days

    {
      destination: next_unbooked,
      days_until_check_in: days_until,
      city: next_unbooked.city,
      state: next_unbooked.state
    }
  end

  # Check if this stay needs a booking alert (unbooked and within threshold)
  def needs_booking_alert?
    return false if booked?
    return false unless days_until_check_in

    days_until_check_in <= BOOKING_ALERT_MONTHS_THRESHOLD * 30
  end

  def self.last_booked_stay
    order(:check_out).last
  end

  # Weather data methods
  def fetch_weather!
    return unless latitude.present? && longitude.present?
    return unless check_in.present? && check_out.present?

    weather = WeatherService.fetch_historical_weather(
      lat: latitude,
      lng: longitude,
      start_date: check_in,
      end_date: check_out
    )

    if weather
      update_columns(
        weather_data: weather.to_json,
        weather_fetched_at: Time.current
      )
    end

    weather
  end

  def weather_stale?
    return true unless weather_fetched_at.present?
    weather_fetched_at < 7.days.ago
  end

  def expected_weather
    return nil unless weather_data.present?
    JSON.parse(weather_data).deep_symbolize_keys
  rescue JSON::ParserError
    nil
  end

  # Check if this stay has dates set (not a wishlist item)
  def has_dates?
    check_in.present? && check_out.present?
  end

  # Wishlist stays without dates
  def wishlist?
    !has_dates?
  end

  private

  def set_default_title
    return if title.present?
    return unless city.present?

    self.title = [ city, state.presence || country ].compact.join(", ")
  end

  def check_out_after_check_in
    return unless check_in && check_out
    if check_out <= check_in
      errors.add(:check_out, "must be after check-in date")
    end
  end

  def no_overlapping_stays
    return unless check_in && check_out
    if overlapping_stays.exists?
      errors.add(:base, "Dates overlap with an existing stay")
    end
  end

  def should_geocode?
    (address_changed? || city_changed? || country_changed?) && full_address.present?
  end

  def location_changed?
    saved_change_to_latitude? || saved_change_to_longitude?
  end

  def clear_cached_location_data
    pois.destroy_all
    transit_routes.destroy_all
    update_columns(weather_data: nil, weather_fetched_at: nil) if weather_data.present?
  end

  def update_status
    # Wishlist stays without dates are always "upcoming"
    unless has_dates?
      self.status = "upcoming"
      return
    end

    today = Date.current
    self.status = if check_out < today
                    "past"
    elsif check_in <= today && check_out >= today
                    "current"
    else
                    "upcoming"
    end
  end

  def should_fetch_pois?
    latitude.present? && longitude.present? &&
      (saved_change_to_latitude? || saved_change_to_longitude? || pois_cached_categories.blank?)
  end

  def enqueue_poi_fetch
    FetchBrowsablePoisJob.perform_later(id)
  end
end
