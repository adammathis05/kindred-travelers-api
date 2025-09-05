class Tribe < ApplicationRecord
    # Associations
  has_many :users, dependent: :destroy
  has_many :reservations, dependent: :destroy
  has_many :vision_board_items, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :invite_code, presence: true, uniqueness: true
  validates :total_budget, numericality: { greater_than: 0 }, allow_nil: true
  validates :current_expenses, numericality: { greater_than_or_equal_to: 0 }

  # Callbacks
  before_validation :generate_invite_code, on: :create
  after_update :update_expenses, if: :saved_change_to_current_expenses?

  # Scopes
  scope :active, -> { joins(:users).group('tribes.id').having('COUNT(users.id) > 0') }
  scope :by_destination, ->(destination) { where(destination: destination) }

  # Instance methods
  def admin_users
    users.where(admin: true)
  end

  def member_count
    users.count
  end

  def total_reservations
    reservations.count
  end

  def upcoming_reservations
    reservations.where('start_date > ?', Time.current).order(:start_date)
  end

  def past_reservations
    reservations.where('end_date < ?', Time.current).order(start_date: :desc)
  end

  def current_reservations
    reservations.where(
      'start_date <= ? AND (end_date >= ? OR end_date IS NULL)',
      Time.current, Time.current
    ).order(:start_date)
  end

  def budget_remaining
    return nil unless total_budget.present?
    total_budget - current_expenses
  end

  def budget_percentage_used
    return 0 unless total_budget.present? && total_budget > 0
    (current_expenses / total_budget * 100).round(2)
  end

  def over_budget?
    return false unless total_budget.present?
    current_expenses > total_budget
  end

  def calculate_total_expenses
    reservations.sum(:cost) || 0
  end

  def update_expenses!
    update!(current_expenses: calculate_total_expenses)
  end

  def vision_board_summary
    {
      total_items: vision_board_items.count,
      by_type: vision_board_items.group(:item_type).count,
      achieved: vision_board_items.where(achieved: true).count,
      high_priority: vision_board_items.where('priority >= ?', 4).count
    }
  end

  private

  def generate_invite_code
    self.invite_code = SecureRandom.hex(4).upcase until invite_code_unique?
  end

  def invite_code_unique?
    invite_code.present? && !Tribe.exists?(invite_code: invite_code)
  end

  def update_expenses
    # You might want to add logic here to notify users about budget changes
  end
end
