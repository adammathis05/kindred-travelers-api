class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable

  # Associations
  belongs_to :tribe
  has_many :reservations, dependent: :destroy
  has_many :vision_board_items, dependent: :destroy

  # Validations
  validates :first_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :last_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, presence: true, uniqueness: true

  # Scopes
  scope :admins, -> { where(admin: true) }
  scope :by_tribe, ->(tribe_id) { where(tribe_id: tribe_id) }

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def admin?
    admin
  end

  def tribe_member?(tribe)
    self.tribe == tribe
  end

  def total_expenses
    reservations.sum(:cost) || 0
  end

  # Class methods
  def self.create_with_tribe(user_params, tribe_params = nil, invite_code = nil)
    ActiveRecord::Base.transaction do
      if invite_code.present?
        # Join existing tribe
        tribe = Tribe.find_by!(invite_code: invite_code)
        user = tribe.users.build(user_params)
      else
        # Create new tribe
        tribe = Tribe.create!(tribe_params)
        user = tribe.users.build(user_params.merge(admin: true))
      end
      
      user.save!
      user
    end
  rescue ActiveRecord::RecordInvalid => e
    raise e
  rescue ActiveRecord::RecordNotFound
    raise ActiveRecord::RecordInvalid.new(User.new.tap { |u| u.errors.add(:invite_code, "is invalid") })
  end
end
