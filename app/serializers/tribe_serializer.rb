class TribeSerializer
  include JSONAPI::Serializer
  
  attributes :id, :name, :description, :destination, :start_date, :end_date, 
             :total_budget, :current_expenses, :created_at, :updated_at
  
  attribute :invite_code do |tribe|
    tribe.invite_code
  end
  
  attribute :member_count do |tribe|
    tribe.member_count
  end
  
  attribute :budget_remaining do |tribe|
    tribe.budget_remaining
  end
  
  attribute :budget_percentage_used do |tribe|
    tribe.budget_percentage_used
  end
  
  attribute :over_budget do |tribe|
    tribe.over_budget?
  end
  
  attribute :days_until_start do |tribe|
    return nil unless tribe.start_date
    return 0 if tribe.start_date <= Date.current
    (tribe.start_date - Date.current).to_i
  end
  
  attribute :days_remaining do |tribe|
    return nil unless tribe.end_date
    return 0 if tribe.end_date <= Date.current
    (tribe.end_date - Date.current).to_i
  end
  
  attribute :trip_duration_days do |tribe|
    return nil unless tribe.start_date && tribe.end_date
    (tribe.end_date - tribe.start_date).to_i + 1
  end
  
  attribute :stats do |tribe|
    {
      total_reservations: tribe.total_reservations,
      vision_items: tribe.vision_board_items.count,
      achieved_vision_items: tribe.vision_board_items.achieved.count,
      achievement_rate: tribe.vision_board_items.achievement_rate
    }
  end
  
  has_many :users, serializer: :user
  has_many :reservations, serializer: :reservation
  has_many :vision_board_items, serializer: :vision_board_item
end