class Api::V1::ReservationsController < Api::V1::BaseController
  before_action :set_tribe, only: [:index, :create]
  before_action :set_reservation, only: [:show, :update, :destroy, :update_status]
  before_action :ensure_tribe_member
  before_action :ensure_owner_or_admin, only: [:update, :destroy]

  def index
    reservations = @tribe.reservations.includes(:user)
    
    # Apply filters
    reservations = apply_filters(reservations, filter_params)
    
    # Apply pagination
    page = pagination_params[:page].to_i
    per_page = pagination_params[:per_page]
    total_count = reservations.count
    reservations = reservations.offset((page - 1) * per_page).limit(per_page)
    
    data = {
      reservations: reservations.map do |reservation|
        ReservationSerializer.new(reservation).serializable_hash[:data][:attributes]
      end,
      pagination: {
        current_page: page,
        per_page: per_page,
        total_count: total_count,
        total_pages: (total_count.to_f / per_page).ceil
      },
      summary: {
        total_cost: @tribe.reservations.confirmed.sum(:cost),
        by_type: @tribe.reservations.confirmed.group(:reservation_type).count,
        by_status: @tribe.reservations.group(:status).count
      }
    }
    
    render_success(data)
  end

  def show
    render_success(
      ReservationSerializer.new(@reservation).serializable_hash[:data][:attributes]
    )
  end

  def create
    @reservation = @tribe.reservations.build(reservation_params)
    @reservation.user = current_user
    
    if @reservation.save
      render_success(
        ReservationSerializer.new(@reservation).serializable_hash[:data][:attributes],
        'Reservation created successfully',
        :created
      )
    else
      render_validation_errors(@reservation)
    end
  end

  def update
    if @reservation.update(reservation_params)
      render_success(
        ReservationSerializer.new(@reservation).serializable_hash[:data][:attributes],
        'Reservation updated successfully'
      )
    else
      render_validation_errors(@reservation)
    end
  end

  def destroy
    if @reservation.destroy
      render_success(nil, 'Reservation deleted successfully')
    else
      render_error('Failed to delete reservation')
    end
  end

  def update_status
    if @reservation.update(status: params[:status])
      render_success(
        ReservationSerializer.new(@reservation).serializable_hash[:data][:attributes],
        'Status updated successfully'
      )
    else
      render_validation_errors(@reservation)
    end
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

  def set_reservation
    @reservation = if params[:tribe_id]
                     Tribe.find(params[:tribe_id]).reservations.find(params[:id])
                   else
                     Reservation.find(params[:id])
                   end
    
    @tribe = @reservation.tribe
  rescue ActiveRecord::RecordNotFound
    render_error('Reservation not found', :not_found)
  end

  def ensure_owner_or_admin
    unless @reservation.user == current_user || current_user.admin?
      render_error('Access denied. You can only modify your own reservations unless you are an admin.', :forbidden)
    end
  end

  def reservation_params
    params.require(:reservation).permit(
      :title, :description, :reservation_type, :start_date, :end_date,
      :cost, :location, :confirmation_number, :notes, :status
    )
  end

  def apply_filters(reservations, filters)
    reservations = reservations.by_type(filters[:type]) if filters[:type].present?
    reservations = reservations.where(status: filters[:status]) if filters[:status].present?
    
    if filters[:start_date].present? && filters[:end_date].present?
      reservations = reservations.by_date_range(filters[:start_date], filters[:end_date])
    end
    
    if filters[:search].present?
      search_term = "%#{filters[:search]}%"
      reservations = reservations.where(
        "title ILIKE ? OR description ILIKE ? OR location ILIKE ? OR confirmation_number ILIKE ?",
        search_term, search_term, search_term, search_term
      )
    end
    
    reservations.order(start_date: :desc, created_at: :desc)
  end
end