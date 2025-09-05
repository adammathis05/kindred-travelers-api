class Api::V1::VisionBoardItemsController < Api::V1::BaseController
  before_action :set_tribe, only: [:index, :create]
  before_action :set_vision_board_item, only: [:show, :update, :destroy, :toggle_achieved]
  before_action :ensure_tribe_member
  before_action :ensure_owner_or_admin, only: [:update, :destroy]

  def index
    items = @tribe.vision_board_items.includes(:user)
    
    # Apply filters
    items = apply_filters(items, filter_params)
    
    # Apply pagination
    page = pagination_params[:page].to_i
    per_page = pagination_params[:per_page]
    total_count = items.count
    items = items.offset((page - 1) * per_page).limit(per_page)
    
    data = {
      vision_board_items: items.map do |item|
        VisionBoardItemSerializer.new(item).serializable_hash[:data][:attributes]
      end,
      pagination: {
        current_page: page,
        per_page: per_page,
        total_count: total_count,
        total_pages: (total_count.to_f / per_page).ceil
      },
      summary: {
        total_items: @tribe.vision_board_items.count,
        achieved_items: @tribe.vision_board_items.achieved.count,
        achievement_rate: @tribe.vision_board_items.achievement_rate,
        by_type: @tribe.vision_board_items.group(:item_type).count,
        by_priority: @tribe.vision_board_items.priority_distribution
      }
    }
    
    render_success(data)
  end

  def show
    render_success(
      VisionBoardItemSerializer.new(@vision_board_item).serializable_hash[:data][:attributes]
    )
  end

  def create
    @vision_board_item = @tribe.vision_board_items.build(vision_board_item_params)
    @vision_board_item.user = current_user
    
    if @vision_board_item.save
      render_success(
        VisionBoardItemSerializer.new(@vision_board_item).serializable_hash[:data][:attributes],
        'Vision board item created successfully',
        :created
      )
    else
      render_validation_errors(@vision_board_item)
    end
  end

  def update
    if @vision_board_item.update(vision_board_item_params)
      render_success(
        VisionBoardItemSerializer.new(@vision_board_item).serializable_hash[:data][:attributes],
        'Vision board item updated successfully'
      )
    else
      render_validation_errors(@vision_board_item)
    end
  end

  def destroy
    if @vision_board_item.destroy
      render_success(nil, 'Vision board item deleted successfully')
    else
      render_error('Failed to delete vision board item')
    end
  end

  def toggle_achieved
    @vision_board_item.toggle_achieved!
    
    status_message = @vision_board_item.achieved? ? 'marked as achieved' : 'marked as pending'
    
    render_success(
      VisionBoardItemSerializer.new(@vision_board_item).serializable_hash[:data][:attributes],
      "Vision board item #{status_message}"
    )
  rescue ActiveRecord::RecordInvalid => e
    render_validation_errors(@vision_board_item)
  end

  private

  def set_tribe
    @tribe = if params[:tribe_id]
               Tribe.find(params[:tribe_id])
             else
               current_user.tribe
             end
  rescue ActiveRecord::RecordNotFound
    render_error('Tribe not found', :not_found)
  end

  def set_vision_board_item
    @vision_board_item = if params[:tribe_id]
                           Tribe.find(params[:tribe_id]).vision_board_items.find(params[:id])
                         else
                           VisionBoardItem.find(params[:id])
                         end
    
    @tribe = @vision_board_item.tribe
  rescue ActiveRecord::RecordNotFound
    render_error('Vision board item not found', :not_found)
  end

  def ensure_owner_or_admin
    unless @vision_board_item.user == current_user || current_user.admin?
      render_error('Access denied. You can only modify your own vision board items unless you are an admin.', :forbidden)
    end
  end

  def vision_board_item_params
    params.require(:vision_board_item).permit(
      :title, :description, :item_type, :priority, :image_url, :link_url, :achieved
    )
  end

  def apply_filters(items, filters)
    items = items.by_type(filters[:type]) if filters[:type].present?
    items = items.where(priority: filters[:priority]) if filters[:priority].present?
    items = items.where(achieved: filters[:achieved]) if filters.key?(:achieved)
    
    if filters[:search].present?
      search_term = "%#{filters[:search]}%"
      items = items.where(
        "title ILIKE ? OR description ILIKE ?",
        search_term, search_term
      )
    end
    
    items.by_priority
  end
end
