class UserSerializer
  include JSONAPI::Serializer
  
  attributes :id, :email, :first_name, :last_name, :admin, :created_at, :updated_at
  
  attribute :full_name do |user|
    user.full_name
  end
  
  attribute :tribe_id do |user|
    user.tribe_id
  end
  
  attribute :total_expenses do |user|
    user.total_expenses
  end
  
  attribute :stats do |user|
    {
      reservations_count: user.reservations.count,
      vision_items_count: user.vision_board_items.count,
      achieved_items_count: user.vision_board_items.achieved.count
    }
  end
  
  belongs_to :tribe, serializer: :tribe
end