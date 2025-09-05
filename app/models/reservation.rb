class Reservation < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :tribe

  # Validations
  validates :title, presence: true, length: { minimum: 2, maximum: 200 }
  validates :reservation_type, presence: true, inclusion: { 
    in: %w[flight hotel activity restaurant transport other],
    message: "%{value} is not a valid reservation type" 
  }
  validates :cost, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :status, inclusion: { in: %w[pending confirmed cancelled] }
  validate :end_date_after_start_date, if: :both_dates_present?

  # Callbacks
  after_save :update_tribe_expenses, if: :saved_change_to_cost?
  after_destroy :update_tribe_expenses

  # Scopes
  scope :by_type, ->(type) { where(reservation_type: type) }
  scope :confirmed, -> { where(status: 'confirmed') }
  scope :pending, -> { where(status: 'pending') }
  scope :cancelled, -> { where(status: 'cancelled') }
  scope :upcoming, -> { where('start_date > ?', Time.current) }
  scope :past, -> { where('end_date < ?', Time.current) }
  scope :current, -> { where('start_date <= ? AND (end_date >= ? OR end_date IS NULL)', Time.current, Time.current) }
  scope :by_date_range, ->(start_date, end_date) { where(start_date: start_date..end_date) }
  scope :with_cost, -> { where.not(cost: nil) }
  scope :expensive, ->(amount = 500) { where('cost >= ?', amount) }

  # Enums (if you prefer enum over string validation)
  # enum reservation_type: { flight: 0, hotel: 1, activity: 2, restaurant: 3, transport: 4, other: 5 }
  # enum status: { pending: 0, confirmed: 1, cancelled: 2 }

  # Instance methods
  def duration_days
    return nil unless start_date && end_date
    ((end_date.to_date - start_date.to_date).to_i + 1)
  end

  def cost_per_day
    return nil unless cost && duration_days && duration_days > 0
    cost / duration_days
  end

  def upcoming?
    start_date && start_date > Time.current
  end

  def past?
    end_date && end_date < Time.current
  end

  def current?
    return false unless start_date
    end_condition = end_date ? end_date >= Time.current : true
    start_date <= Time.current && end_condition
  end

  def confirmed?
    status == 'confirmed'
  end

  def pending?
    status == 'pending'
  end

  def cancelled?
    status == 'cancelled'
  end

  def type_icon
    case reservation_type
    when 'flight' then '✈️'
    when 'hotel' then '🏨'
    when 'activity' then '🎯'
    when 'restaurant' then '🍽️'
    when 'transport' then '🚗'
    else '📋'
    end
  end

  def formatted_dates
    return start_date.strftime("%b %d, %Y") unless end_date
    
    if start_date.to_date == end_date.to_date
      start_date.strftime("%b %d, %Y")
    else
      "#{start_date.strftime("%b %d")} - #{end_date.strftime("%b %d, %Y")}"
    end
  end

  # Class methods
  def self.total_cost
    confirmed.sum(:cost) || 0
  end

  def self.by_month(year = Date.current.year)
    confirmed.where(start_date: Date.new(year, 1, 1)..Date.new(year, 12, 31))
            .group("DATE_TRUNC('month', start_date)")
            .sum(:cost)
  end

  def self.expense_breakdown
    confirmed.group(:reservation_type).sum(:cost)
  end

  private

  def both_dates_present?
    start_date.present? && end_date.present?
  end

  def end_date_after_start_date
    return unless both_dates_present?
    errors.add(:end_date, "must be after start date") if end_date < start_date
  end

  def update_tribe_expenses
    tribe.update_expenses! if tribe
  end
end
