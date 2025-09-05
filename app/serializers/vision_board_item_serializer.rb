class VisionBoardItemSerializer
  include JSONAPI::Serializer
  
  attributes :id, :title, :description, :item_type, :priority, :image_url, :link_url,
             :achieved, :created_at, :updated_at
  
  attribute :priority_label do |item|
    item.priority_label
  end
  
  attribute :priority_color do |item|
    item.priority_color
  end
  
  attribute :type_icon do |item|
    item.type_icon
  end
  
  attribute :type_label do |item|
    item.type_label
  end
  
  attribute :has_image do |item|
    item.has_image?
  end
  
  attribute :has_link do |item|
    item.has_link?
  end
  
  attribute :days_since_created do |item|
    item.days_since_created
  end
  
  attribute :created_by do |item|
    {
      id: item.user.id,
      name: item.user.full_name,
      email: item.user.email
    }
  end
  
  belongs_to :user, serializer: :user
  belongs_to :tribe, serializer: :tribe
end