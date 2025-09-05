class Api::V1::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    if params[:invite_code].present?
      join_existing_tribe
    else
      create_new_tribe
    end
  end

  private

  def join_existing_tribe
    tribe = Tribe.find_by(invite_code: params[:invite_code])
    
    unless tribe
      render json: { error: 'Invalid invite code' }, status: :unprocessable_entity
      return
    end

    user = tribe.users.build(sign_up_params)
    
    if user.save
      render json: {
        message: 'Successfully joined tribe!',
        data: {
          user: UserSerializer.new(user).serializable_hash[:data][:attributes],
          tribe: TribeSerializer.new(tribe).serializable_hash[:data][:attributes]
        }
      }, status: :created
    else
      render json: {
        error: 'Registration failed',
        errors: user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def create_new_tribe
    tribe_params = params.require(:tribe).permit(:name, :description, :destination, :start_date, :end_date, :total_budget)
    
    ActiveRecord::Base.transaction do
      tribe = Tribe.create!(tribe_params)
      user = tribe.users.build(sign_up_params.merge(admin: true))
      
      if user.save
        render json: {
          message: 'Account and tribe created successfully!',
          data: {
            user: UserSerializer.new(user).serializable_hash[:data][:attributes],
            tribe: TribeSerializer.new(tribe).serializable_hash[:data][:attributes],
            invite_code: tribe.invite_code
          }
        }, status: :created
      else
        raise ActiveRecord::Rollback
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: {
      error: 'Registration failed',
      errors: e.record.errors.full_messages
    }, status: :unprocessable_entity
  rescue ActiveRecord::Rollback
    render json: {
      error: 'Registration failed',
      errors: user.errors.full_messages
    }, status: :unprocessable_entity
  end

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        message: 'Signed up successfully',
        data: {
          user: UserSerializer.new(resource).serializable_hash[:data][:attributes],
          tribe: TribeSerializer.new(resource.tribe).serializable_hash[:data][:attributes]
        }
      }, status: :ok
    else
      render json: {
        error: 'Registration failed',
        errors: resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
end