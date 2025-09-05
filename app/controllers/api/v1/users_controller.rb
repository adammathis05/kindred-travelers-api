class Api::V1::UsersController < Api::V1::BaseController
  before_action :set_user, only: [:show, :update, :dashboard, :expenses_summary]
  before_action :ensure_current_user_or_admin, only: [:show, :update]

  def show
    render_success(
      user: UserSerializer.new(@user).serializable_hash[:data][:attributes],
      tribe: TribeSerializer.new(@user.tribe).serializable_hash[:data][:attributes]
    )
  end

  def update
    if @user.update(user_params)
      render_success(
        UserSerializer.new(@user).serializable_hash[:data][:attributes],
        'Profile updated successfully'
      )
    else
      render_validation_errors(@user)
    end
  end

  def dashboard
    data = {
      user: UserSerializer.new(@user).serializable_hash[:data][:attributes],
      tribe: TribeSerializer.new(@user.tribe).serializable_hash[:data][:attributes],
      recent_reservations: @user.reservations.recent.limit(5).map do |reservation|
        ReservationSerializer.new(reservation).serializable_hash[:data][:attributes]
      end,
      recent_vision_items: @user.vision_board_items.recent.limit(5).map do |item|
        VisionBoardItemSerializer.new(item).serializable_hash[:data][:attributes]
      end,
      stats: {
        total_reservations: @user.reservations.count,
        total_vision_items: @user.vision_board_items.count,
        achieved_items: @user.vision_board_items.achieved.count,
        total_expenses: @user.total_expenses
      }
    }
    
    render_success(data)
  end

  def expenses_summary
    reservations = @user.reservations.confirmed
    
    data = {
      total_expenses: reservations.sum(:cost),
      by_type: reservations.group(:reservation_type).sum(:cost),
      by_month: reservations.group_by_month(:start_date).sum(:cost),
      recent_expenses: reservations.order(created_at: :desc).limit(10).map do |reservation|
        ReservationSerializer.new(reservation).serializable_hash[:data][:attributes]
      end
    }
    
    render_success(data)
  end

  private

  def set_user
    @user = params[:id] == 'me' ? current_user : User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_error('User not found', :not_found)
  end

  def ensure_current_user_or_admin
    unless @user == current_user || current_user.admin?
      render_error('Access denied', :forbidden)
    end
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email)
  end
end