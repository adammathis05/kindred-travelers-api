require 'factory_bot_rails'

puts "🌱 Starting to seed the database with FactoryBot..."

# Clear existing data in development
if Rails.env.development?
  puts "🧹 Clearing existing data..."
  VisionBoardItem.destroy_all
  Reservation.destroy_all
  User.destroy_all
  Tribe.destroy_all
  puts "✅ Data cleared!"
end

puts "🏕️ Creating sample tribes..."

# Create diverse tribes with different themes
tribes = []

# 1. Tokyo Adventure - Group of friends
tokyo_tribe = FactoryBot.create(:tribe, :tokyo_trip, :group_adventure)
tribes << tokyo_tribe

# 2. European Backpackers - Budget travelers
europe_tribe = FactoryBot.create(:tribe, :europe_trip, :backpacking)
tribes << europe_tribe

# 3. Bali Retreat - Luxury trip
bali_tribe = FactoryBot.create(:tribe, :bali_trip, :luxury_trip)
tribes << bali_tribe

# 4. Random adventure trip
random_tribe = FactoryBot.create(:tribe, :budget_trip)
tribes << random_tribe

puts "✅ Created #{tribes.count} tribes:"
tribes.each { |tribe| puts "   - #{tribe.name} (#{tribe.invite_code})" }

puts "👥 Creating users and assigning to tribes..."

# Create users for each tribe
tribes.each_with_index do |tribe, index|
  puts "   Creating users for #{tribe.name}..."
  
  # Create tribe admin (first user)
  admin = FactoryBot.create(:user, :admin, :with_common_names, tribe: tribe)
  puts "     🛡️  Admin: #{admin.full_name} (#{admin.email})"
  
  # Create 2-4 regular members
  member_count = rand(2..4)
  members = FactoryBot.create_list(:user, member_count, :with_common_names, tribe: tribe)
  members.each do |member|
    puts "     👤 Member: #{member.full_name} (#{member.email})"
  end
  
  tribe.reload
  puts "     📊 Total members: #{tribe.member_count}"
end

puts "📋 Creating reservations for each tribe..."

tribes.each do |tribe|
  puts "   Creating reservations for #{tribe.name}..."
  
  tribe.users.each do |user|
    # Create 1-3 reservations per user
    reservation_count = rand(1..3)
    
    case tribe.destination
    when /Tokyo/
      # Tokyo-specific reservations
      FactoryBot.create(:reservation, :flight, :confirmed, user: user, tribe: tribe)
      FactoryBot.create(:reservation, :hotel, :confirmed, user: user, tribe: tribe) if rand < 0.8
      FactoryBot.create_list(:reservation, rand(1..2), :activity, :confirmed, user: user, tribe: tribe)
    when /European/
      # Europe-specific reservations
      FactoryBot.create(:reservation, :flight, :confirmed, user: user, tribe: tribe)
      FactoryBot.create(:reservation, :transport, :confirmed, user: user, tribe: tribe)
      FactoryBot.create_list(:reservation, rand(1..3), [:hotel, :activity].sample, :confirmed, user: user, tribe: tribe)
    when /Bali/
      # Bali-specific reservations
      FactoryBot.create(:reservation, :flight, :confirmed, user: user, tribe: tribe)
      FactoryBot.create(:reservation, :hotel, :confirmed, user: user, tribe: tribe)
      FactoryBot.create_list(:reservation, rand(2..3), :activity, :confirmed, user: user, tribe: tribe)
    else
      # Generic reservations
      FactoryBot.create_list(:reservation, reservation_count, :confirmed, user: user, tribe: tribe)
    end
    
    # Add some pending/cancelled reservations for variety
    FactoryBot.create(:reservation, :pending, user: user, tribe: tribe) if rand < 0.3
    FactoryBot.create(:reservation, :cancelled, user: user, tribe: tribe) if rand < 0.1
  end
  
  tribe.reload
  puts "     📋 Total reservations: #{tribe.reservations.count}"
end

puts "💡 Creating vision board items for each tribe..."

tribes.each do |tribe|
  puts "   Creating vision board items for #{tribe.name}..."
  
  tribe.users.each do |user|
    # Create 2-5 vision board items per user
    item_count = rand(2..5)
    
    case tribe.destination
    when /Tokyo/
      # Tokyo-specific items
      FactoryBot.create_list(:vision_board_item, rand(1..2), :tokyo_item, :high_priority, user: user, tribe: tribe)
      FactoryBot.create_list(:vision_board_item, rand(1..3), :activity, user: user, tribe: tribe)
    when /European/
      # Europe-specific items
      FactoryBot.create_list(:vision_board_item, rand(1..2), :europe_item, :high_priority, user: user, tribe: tribe)
      FactoryBot.create_list(:vision_board_item, rand(2..3), [:place, :food].sample, user: user, tribe: tribe)
    when /Bali/
      # Bali-specific items
      FactoryBot.create_list(:vision_board_item, rand(1..2), :bali_item, :high_priority, user: user, tribe: tribe)
      FactoryBot.create_list(:vision_board_item, rand(1..2), :inspiration, :with_image, user: user, tribe: tribe)
    else
      # Generic items
      FactoryBot.create_list(:vision_board_item, item_count, user: user, tribe: tribe)
    end
    
    # Mark some items as achieved
    user.vision_board_items.limit(rand(0..2)).update_all(achieved: true)
  end
  
  tribe.reload
  puts "     💡 Total vision items: #{tribe.vision_board_items.count}"
  puts "     ✅ Achieved items: #{tribe.vision_board_items.achieved.count}"
end

puts "💰 Updating tribe expenses..."

# Update all tribe expenses based on confirmed reservations
tribes.each do |tribe|
  tribe.update_expenses!
  puts "   #{tribe.name}: $#{tribe.current_expenses} / $#{tribe.total_budget}"
end

puts "\n🎉 SEED DATA SUMMARY"
puts "=" * 50
puts "Tribes Created: #{Tribe.count}"
puts "Users Created: #{User.count}"
puts "Reservations Created: #{Reservation.count}"
puts "Vision Board Items Created: #{VisionBoardItem.count}"

puts "\n🔐 SAMPLE LOGIN CREDENTIALS"
puts "=" * 50

Tribe.includes(:users).each do |tribe|
  admin = tribe.users.find_by(admin: true)
  puts "\n#{tribe.name}:"
  puts "  🎯 Destination: #{tribe.destination}"
  puts "  📅 Dates: #{tribe.start_date} to #{tribe.end_date}"
  puts "  💰 Budget: $#{tribe.total_budget} (Used: $#{tribe.current_expenses})"
  puts "  🔑 Invite Code: #{tribe.invite_code}"
  puts "  👑 Admin: #{admin.email} / password123"
  
  tribe.users.where(admin: false).limit(2).each do |user|
    puts "  👤 Member: #{user.email} / password123"
  end
end

puts "\n🚀 Ready to test your API!"
puts "Try logging in with any of the credentials above."
puts "All tribes have realistic reservations and vision board items to explore."