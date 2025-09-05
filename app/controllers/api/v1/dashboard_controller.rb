class Api::V1::DashboardController < Api::V1::BaseController
  def index
    tribe = @current_tribe
    user = current_user
    
    # Get recent activity across the tribe
    recent_reservations = tribe.reservations.order(created_at: :desc).limit(10).includes(:user)
    recent_vision_items = tribe.vision_board_items.order(created_at: :desc).limit(10).includes(:user)
    upcoming_reservations = tribe.upcoming_reservations.limit(5).includes(:user)
    
    # Calculate statistics
    tribe_stats = {
      member_count: tribe.member_count,
      total_reservations: tribe.total_reservations,
      total_vision_items: tribe.vision_board_items.count,
      achieved_vision_items: tribe.vision_board_items.achieved.count,
      achievement_rate: tribe.vision_board_items.achievement_rate,
      total_expenses: tribe.current_expenses,
      budget_remaining: tribe.budget_remaining,
      budget_percentage_used: tribe.budget_percentage_used,
      over_budget: tribe.over_budget?
    }
    
    user_stats = {
      user_reservations: user.reservations.count,
      user_vision_items: user.vision_board_items.count,
      user_achieved_items: user.vision_board_items.achieved.count,
      user_expenses: user.total_expenses
    }
    
    # Expense breakdown
    expense_breakdown = {
      by_type: tribe.reservations.confirmed.group(:reservation_type).sum(:cost),
      by_user: tribe.users.joins(:reservations)
                         .where(reservations: { status: 'confirmed' })
                         .group('users.id', 'users.first_name', 'users.last_name')
                         .sum('reservations.cost')
                         .transform_keys { |k| "#{k[1]} #{k[2]}" },
      recent_month: tribe.reservations.confirmed
                          .where('created_at >= ?', 1.month.ago)
                          .sum(:cost)
    }
    
    # Vision board insights
    vision_insights = {
      by_type: tribe.vision_board_items.group(:item_type).count,
      by_priority: tribe.vision_board_items.group(:priority).count.transform_keys do |priority|
        VisionBoardItem.new(priority: priority).priority_label
      end,
      high_priority_pending: tribe.vision_board_items.high_priority.pending.count,
      recently_achieved: tribe.vision_board_items.achieved
                              .where('updated_at >= ?', 1.week.ago)
                              .count
    }
    
    # Upcoming events/deadlines
    upcoming_events = []
    
    # Add trip start/end dates
    if tribe.start_date && tribe.start_date > Date.current
      days_until = (tribe.start_date - Date.current).to_i
      upcoming_events << {
        type: 'trip_start',
        title: 'Trip begins',
        date: tribe.start_date,
        days_until: days_until,
        description: "Your adventure to #{tribe.destination} starts!"
      }
    end
    
    if tribe.end_date && tribe.end_date > Date.current
      days_until = (tribe.end_date - Date.current).to_i
      upcoming_events << {
        type: 'trip_end',
        title: 'Trip ends',
        date: tribe.end_date,
        days_until: days_until,
        description: 'Last day of your adventure'
      }
    end
    
    # Add upcoming reservations as events
    upcoming_reservations.each do |reservation|
      if reservation.start_date && reservation.start_date > Time.current
        days_until = ((reservation.start_date.to_date - Date.current).to_i)
        upcoming_events << {
          type: 'reservation',
          title: reservation.title,
          date: reservation.start_date.to_date,
          days_until: days_until,
          description: reservation.description,
          reservation_type: reservation.reservation_type
        }
      end
    end
    
    # Sort events by date
    upcoming_events.sort_by! { |event| event[:date] }
    upcoming_events = upcoming_events.first(10)
    
    data = {
      tribe: TribeSerializer.new(tribe).serializable_hash[:data][:attributes],
      user: UserSerializer.new(user).serializable_hash[:data][:attributes],
      tribe_stats: tribe_stats,
      user_stats: user_stats,
      recent_activity: {
        reservations: recent_reservations.map do |reservation|
          ReservationSerializer.new(reservation).serializable_hash[:data][:attributes]
        end,
        vision_items: recent_vision_items.map do |item|
          VisionBoardItemSerializer.new(item).serializable_hash[:data][:attributes]
        end
      },
      upcoming_reservations: upcoming_reservations.map do |reservation|
        ReservationSerializer.new(reservation).serializable_hash[:data][:attributes]
      end,
      upcoming_events: upcoming_events,
      expense_breakdown: expense_breakdown,
      vision_insights: vision_insights,
      quick_actions: [
        {
          type: 'add_reservation',
          title: 'Add Reservation',
          description: 'Book a new flight, hotel, or activity',
          icon: '📝'
        },
        {
          type: 'add_vision_item',
          title: 'Add to Vision Board',
          description: 'Share inspiration for your trip',
          icon: '💡'
        },
        {
          type: 'invite_member',
          title: 'Invite Member',
          description: "Share code: #{tribe.invite_code}",
          icon: '👥'
        },
        {
          type: 'update_budget',
          title: 'Update Budget',
          description: 'Adjust trip budget and expenses',
          icon: '💰'
        }
      ]
    }
    
    render_success(data)
  end
end