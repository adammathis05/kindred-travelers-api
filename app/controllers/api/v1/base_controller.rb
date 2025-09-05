class Api::V1::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_tribe

  protect_from_forgery with: :null_session
  respond_to :json

  private

  def set_current_tribe
    @current_tribe = current_user&.tribe
  end

  def ensure_tribe_member
    unless current_user&.tribe_member?(@current_tribe)
      render json: { error: 'Access denied. You must be a member of this tribe.' }, status: :forbidden
    end
  end

  def ensure_admin
    unless current_user&.admin?
      render json: { error: 'Access denied. Admin privileges required.' }, status: :forbidden
    end
  end

  def render_success(data = nil, message = nil, status = :ok)
    response = {}
    response[:message] = message if message
    response[:data] = data if data
    render json: response, status: status
  end

  def render_error(message, status = :unprocessable_entity, errors = nil)
    response = { error: message }
    response[:errors] = errors if errors
    render json: response, status: status
  end

  def render_validation_errors(record)
    render json: {
      error: 'Validation failed',
      errors: record.errors.full_messages
    }, status: :unprocessable_entity
  end

  def pagination_params
    {
      page: params[:page] || 1,
      per_page: [params[:per_page]&.to_i || 25, 100].min
    }
  end

  def filter_params
    params.permit(:search, :type, :status, :priority, :achieved, :start_date, :end_date)
  end
end