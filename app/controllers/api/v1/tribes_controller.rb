class Api::V1::TribesController < Api::V1::BaseController
  before_action :set_tribe, only: [:show, :update, :dashboard, :members, :budget_summary, :expense_breakdown]
  before_action :ensure_tribe_member, only: [:show, :dashboard, :members, :budget_summary, :expense_breakdown]
  before_action :ensure_admin, only: [:update]

  def show
    render_success(
      TribeSerializer.new(@tribe).serializable_hash[:data][:attributes]
    )
  end

  def update
    if @tribe.update(tribe_params)
      render_success(
        TribeSerializer.new(@tribe).serializable_hash[:data][:attributes],
        'Tribe updated successfully'
      )
    else
      render_validation_errors(@tribe)
    end
  end

  def dashboard
    data = {
      tribe: TribeSerializer.new(@tribe).serializable_hash[:data][:attributes],
      stats: {
        member_count: @tribe.member_count,
        total_reservations: @tribe.total_reservations,
        total_vision_items: @tribe.vision_board_items.count,
        achieved_items: @tribe.vision_board_items.achieved.count,
        budget_used_percentage: @tribe.budget_percentage_used
      },
      upcoming_reservations: @tribe.upcoming_reservations.limit(5).map do |reservation|
        ReservationSerializer.new(reservation).serializable_hash[:data][:attributes]
      end,
      recent_vision_items: @tribe.vision_board_items.recent.limit(5).map do |item|
        VisionBoardItemSerializer.new(item).serializable_hash[:data][:attributes]
      end,
      budget_summary: {
        total_budget: @tribe.total_budget,
        current_expenses: @tribe.current_expenses,
        remaining_budget: @tribe.budget_remaining,
        over_budget: @tribe.over_budget?
      }
    }
    
    render_success(data)
  end

  def members
    members = @tribe.users.includes(:reservations, :vision_board_items)
    
    data = members.map do |user|
      user_data = UserSerializer.new(user).serializable_hash[:data][:attributes]
      user_data.merge({
        stats: {
          reservations_count: user.reservations.count,
          vision_items_count: user.vision_board_items.count,
          total_expenses: user.total_expenses
        }
      })
    end
    
    render_success(data)
  end

  def budget_summary
    data = {
      tribe: {
        total_budget: @tribe.total_budget,
        current_expenses: @tribe.current_expenses,
        remaining_budget: @tribe.budget_remaining,
        percentage_used: @tribe.budget_percentage_used,
        over_budget: @tribe.over_budget?
      },
      by_type: @tribe.reservations.confirmed.group(:reservation_type).sum(:cost),
      by_user: @tribe.users.joins(:reservations)
                          .where(reservations: { status: 'confirmed' })
                          .group('users.first_name', 'users.last_name')
                          .sum('reservations.cost'),
      monthly_breakdown: @tribe.reservations.confirmed
                               .group_by_month(:start_date, last: 12)
                               .sum(:cost),
      recent_expenses: @tribe.reservations.confirmed
                             .order(created_at: :desc)
                             .limit(10)
                             .includes(:user)
                             .map do |reservation|
        ReservationSerializer.new(reservation).serializable_hash[:data][:attributes]
      end
    }
    
    render_success(data)
  end

  def expense_breakdown
    reservations = @tribe.reservations.confirmed
    
    data = {
      total: reservations.sum(:cost),
      by_type: reservations.group(:reservation_type).sum(:cost),
      by_status: @tribe.reservations.group(:status).sum(:cost),
      by_month: reservations.group_by_month(:start_date).sum(:cost),
      expensive_items: reservations.expensive(500).order(cost: :desc).limit(10).map do |reservation|
        ReservationSerializer.new(reservation).serializable_hash[:data][:attributes]
      end
    }
    
    render_success(data)
  end

  def invite_info
    tribe = Tribe.find_by(invite_code: params[:code])
    
    if tribe
      render_success({
        name: tribe.name,
        description: tribe.description,
        destination: tribe.destination,
        member_count: tribe.member_count,
        start_date: tribe.start_date,
        end_date: tribe.end_date
      })
    else
      render_error('Invalid invite code', :not_found)
    end
  end

  def join_with_code
    tribe = Tribe.find_by(invite_code: params[:invite_code])
    
    unless tribe
      render_error('Invalid invite code', :not_found)
      return
    end

    if current_user.update(tribe: tribe)
      render_success(
        {
          user: UserSerializer.new(current_user).serializable_hash[:data][:attributes],
          tribe: TribeSerializer.new(tribe).serializable_hash[:data][:attributes]
        },
        'Successfully joined tribe!'
      )
    else
      render_validation_errors(current_user)
    end
  end

  private

  def set_tribe
    @tribe = if params[:id] == 'current'
               current_user.tribe
             else
               Tribe.find(params[:id])
             end
  rescue ActiveRecord::RecordNotFound
    render_error('Tribe not found', :not_found)
  end

  def tribe_params
    params.require(:tribe).permit(:name, :description, :destination, :start_date, :end_date, :total_budget)
  end
end