class Stay < ApplicationRecord
  STAY_TYPES = %w[airbnb hotel hostel friend other].freeze
  STATUSES = %w[upcoming current past].freeze
  CURRENCIES = %w[USD EUR GBP JPY AUD CAD CHF CNY INR MXN].freeze

  has_many :pois, dependent: :destroy
  has_many :transit_routes, dependent: :destroy

  validates :title, presence: true
  validates :check_in, presence: true
  validates :check_out, presence: true
  validates :city, presence: true
  validates :stay_type, inclusion: { in: STAY_TYPES }, if: :booked?
  validates :status, inclusion: { in: STATUSES }
  validates :currency, inclusion: { in: CURRENCIES }
  validate :check_out_after_check_in
  validate :no_overlapping_stays, on: :create

  geocoded_by :full_address
  after_validation :geocode, if: :should_geocode?

  before_save :update_status

  scope :upcoming, -> { where(status: 'upcoming').order(:check_in) }
  scope :current, -> { where(status: 'current') }
  scope :past, -> { where(status: 'past').order(check_out: :desc) }
  scope :chronological, -> { order(:check_in) }
  scope :booked, -> { where(booked: true) }
  scope :planned, -> { where(booked: false) }

  def full_address
    [address, city, country].compact.join(', ')
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

  def overlapping_stays
    Stay.where.not(id: id)
        .where('check_in < ? AND check_out > ?', check_out, check_in)
  end

  def self.current_stay
    today = Date.current
    find_by('check_in <= ? AND check_out >= ?', today, today)
  end

  def self.next_upcoming
    upcoming.first
  end

  def self.update_all_statuses!
    today = Date.current
    where('check_out < ?', today).update_all(status: 'past')
    where('check_in <= ? AND check_out >= ?', today, today).update_all(status: 'current')
    where('check_in > ?', today).update_all(status: 'upcoming')
  end

  def self.find_gaps
    gaps = []
    stays = chronological.to_a
    stays.each_cons(2) do |stay1, stay2|
      if stay2.check_in > stay1.check_out
        gaps << {
          start_date: stay1.check_out,
          end_date: stay2.check_in,
          days: (stay2.check_in - stay1.check_out).to_i
        }
      end
    end
    gaps
  end

  # Returns booking alert info if there's an unbooked upcoming stay within the threshold
  # Returns nil if no action needed
  def self.booking_alert(months_threshold: 4)
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

  def self.last_booked_stay
    order(:check_out).last
  end

  private

  def check_out_after_check_in
    return unless check_in && check_out
    if check_out <= check_in
      errors.add(:check_out, 'must be after check-in date')
    end
  end

  def no_overlapping_stays
    return unless check_in && check_out
    if overlapping_stays.exists?
      errors.add(:base, 'Dates overlap with an existing stay')
    end
  end

  def should_geocode?
    return false if latitude.present? && longitude.present?
    (address_changed? || city_changed? || country_changed?) && full_address.present?
  end

  def update_status
    today = Date.current
    self.status = if check_out < today
                    'past'
                  elsif check_in <= today && check_out >= today
                    'current'
                  else
                    'upcoming'
                  end
  end
end
