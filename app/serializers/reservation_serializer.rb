class ReservationSerializer
  include JSONAPI::Serializer
  
  attributes :id, :title, :description, :reservation_type, :start_date, :end_date,
             :cost, :location, :confirmation_number, :notes, :status, :created_at, :updated_at
  
  attribute :type_icon do |reservation|
    reservation.type_icon
  end
  
  attribute :formatted_dates do |reservation|
    reservation.formatted_dates
  end
  
  attribute :duration_days do |reservation|
    reservation.duration_days
  end
  
  attribute :cost_per_day do |reservation|
    reservation.cost_per_day
  end
  
  attribute :upcoming do |reservation|
    reservation.upcoming?
  end
  
  attribute :current do |reservation|
    reservation.current?
  end
  
  attribute :past do |reservation|
    reservation.past?
  end
  
  attribute :days_until_start do |reservation|
    return nil unless reservation.start_date
    return 0 if reservation.start_date <= Time.current
    ((reservation.start_date.to_date - Date.current).to_i)
  end
  
  attribute :created_by do |reservation|
    {
      id: reservation.user.id,
      name: reservation.user.full_name,
      email: reservation.user.email
    }
  end
  
  belongs_to :user, serializer: :user
  belongs_to :tribe, serializer: :tribe
end