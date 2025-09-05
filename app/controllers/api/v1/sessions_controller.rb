class Api::V1::SessionsController < Devise::SessionsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        message: 'Logged in successfully',
        data: {
          user: UserSerializer.new(resource).serializable_hash[:data][:attributes],
          tribe: TribeSerializer.new(resource.tribe).serializable_hash[:data][:attributes]
        }
      }, status: :ok
    else
      render json: {
        error: 'Invalid email or password'
      }, status: :unauthorized
    end
  end

  def respond_to_on_destroy
    if current_user
      render json: {
        message: 'Logged out successfully'
      }, status: :ok
    else
      render json: {
        error: 'Could not log out'
      }, status: :unauthorized
    end
  end
end