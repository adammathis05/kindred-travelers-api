class VisionBoardItem < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :tribe

  # Validations
  validates :title, presence: true, length: { minimum: 2, maximum: 200 }
  validates :item_type, inclusion: { 
    in: %w[inspiration activity place food accommodation],
    message: "%{value} is not a valid item type" 
  }
  validates :priority, inclusion: { in: 1..5 }
  validates :image_url, format: { with: URI::regexp(%w[http https]), message: "must be a valid URL" }, allow_blank: true
  validates :link_url, format: { with: URI::regexp(%w[http https]), message: "must be a valid URL" }, allow_blank: true

  # Scopes
  scope :by_type, ->(type) { where(item_type: type) }
  scope :high_priority, -> { where('priority >= ?', 4) }
  scope :medium_priority, -> { where(priority: [2, 3]) }
  scope :low_priority, -> { where(priority: 1) }
  scope :achieved, -> { where(achieved: true) }
  scope :pending, -> { where(achieved: false) }
  scope :with_images, -> { where.not(image_url: [nil, '']) }
  scope :with_links, -> { where.not(link_url: [nil, '']) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_priority, -> { order(priority: :desc, created_at: :desc) }

  # Instance methods
  def priority_label
    case priority
    when 5 then 'Must Do'
    when 4 then 'High Priority'
    when 3 then 'Medium Priority'
    when 2 then 'Low Priority'
    when 1 then 'Nice to Have'
    else 'Unknown'
    end
  end

  def priority_color
    case priority
    when 5 then '#dc2626' # red-600
    when 4 then '#ea580c' # orange-600
    when 3 then '#ca8a04' # yellow-600
    when 2 then '#16a34a' # green-600
    when 1 then '#6b7280' # gray-500
    else '#6b7280'
    end
  end

  def type_icon
    case item_type
    when 'inspiration' then '💡'
    when 'activity' then '🎯'
    when 'place' then '📍'
    when 'food' then '🍽️'
    when 'accommodation' then '🏨'
    else '📋'
    end
  end

  def type_label
    item_type.humanize
  end

  def has_image?
    image_url.present?
  end

  def has_link?
    link_url.present?
  end

  def mark_achieved!
    update!(achieved: true)
  end

  def mark_pending!
    update!(achieved: false)
  end

  def toggle_achieved!
    update!(achieved: !achieved)
  end

  def created_by?(user)
    self.user == user
  end

  def days_since_created
    (Time.current.to_date - created_at.to_date).to_i
  end

  # Class methods
  def self.achievement_rate
    return 0 if count == 0
    (achieved.count.to_f / count * 100).round(2)
  end

  def self.by_achievement_status
    {
      achieved: achieved.count,
      pending: pending.count,
      total: count
    }
  end

  def self.priority_distribution
    group(:priority).count.transform_keys { |k| VisionBoardItem.new(priority: k).priority_label }
  end

  def self.type_distribution
    group(:item_type).count.transform_keys { |k| k.humanize }
  end

  def self.recent_activity(limit = 10)
    recent.limit(limit).includes(:user)
  end

  def self.top_priorities(limit = 5)
    high_priority.pending.limit(limit).order(priority: :desc, created_at: :desc)
  end

  # Search functionality
  def self.search(query)
    return all if query.blank?
    
    where("title ILIKE ? OR description ILIKE ?", "%#{query}%", "%#{query}%")
  end

  def self.filter_by_params(params)
    items = all
    items = items.by_type(params[:item_type]) if params[:item_type].present?
    items = items.where(priority: params[:priority]) if params[:priority].present?
    items = items.where(achieved: params[:achieved]) if params.key?(:achieved)
    items = items.search(params[:search]) if params[:search].present?
    items
  end
end
