FactoryBot.define do
  factory :reservation do
    title { "#{reservation_type.humanize}: #{Faker::Lorem.words(number: 2).join(' ').titleize}" }
    description { Faker::Lorem.paragraph(sentence_count: 2) }
    reservation_type { ['flight', 'hotel', 'activity', 'restaurant', 'transport', 'other'].sample }
    start_date { Faker::Date.between(from: user.tribe.start_date, to: user.tribe.end_date) }
    end_date { start_date + rand(1..5).days }
    cost { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    location { user.tribe.destination }
    confirmation_number { Faker::Alphanumeric.alphanumeric(number: 8).upcase }
    notes { [Faker::Lorem.sentence, nil].sample } # Sometimes no notes
    status { ['confirmed', 'pending', 'cancelled'].sample }
    user
    tribe { user.tribe }

    # Specific reservation types with realistic data
    trait :flight do
      reservation_type { 'flight' }
      title { "Flight to #{user.tribe.destination.split(',').first}" }
      description { "#{['Round-trip', 'One-way'].sample} flight #{['from LAX', 'from JFK', 'from ORD', 'from ATL'].sample}" }
      cost { Faker::Number.between(from: 300, to: 1500) }
      start_date { user.tribe.start_date - rand(0..2).days }
      end_date { user.tribe.end_date + rand(0..2).days }
      location { "#{Faker::Address.city} to #{user.tribe.destination}" }
    end

    trait :hotel do
      reservation_type { 'hotel' }
      title { "#{['Hotel', 'Hostel', 'Airbnb', 'Resort'].sample} in #{user.tribe.destination.split(',').first}" }
      description { "#{['Modern', 'Boutique', 'Budget-friendly', 'Luxury'].sample} accommodation in #{['city center', 'downtown', 'near attractions'].sample}" }
      cost { Faker::Number.between(from: 50, to: 300) }
      location { user.tribe.destination }
    end

    trait :activity do
      reservation_type { 'activity' }
      title { "#{['Museum Visit', 'Food Tour', 'Sightseeing', 'Adventure Activity', 'Cultural Experience'].sample}" }
      description { "#{['Half-day', 'Full-day', 'Evening'].sample} #{['guided', 'self-guided'].sample} experience" }
      cost { Faker::Number.between(from: 25, to: 200) }
      end_date { start_date } # Activities usually same day
    end

    trait :restaurant do
      reservation_type { 'restaurant' }
      title { "#{['Dinner', 'Lunch', 'Breakfast'].sample} at #{Faker::Restaurant.name}" }
      description { "#{['Fine dining', 'Casual dining', 'Local cuisine'].sample} experience" }
      cost { Faker::Number.between(from: 15, to: 150) }
      end_date { start_date } # Meals are same day
    end

    trait :transport do
      reservation_type { 'transport' }
      title { "#{['Train', 'Bus', 'Car Rental', 'Airport Transfer'].sample}" }
      description { "Transportation #{['within the city', 'between cities', 'to/from airport'].sample}" }
      cost { Faker::Number.between(from: 10, to: 200) }
    end

    trait :expensive do
      cost { Faker::Number.between(from: 500, to: 2000) }
    end

    trait :budget do
      cost { Faker::Number.between(from: 10, to: 100) }
    end

    trait :confirmed do
      status { 'confirmed' }
    end

    trait :pending do
      status { 'pending' }
    end

    trait :upcoming do
      start_date { Faker::Date.between(from: 1.week.from_now, to: 3.months.from_now) }
      end_date { start_date + rand(1..3).days }
    end

    trait :past do
      start_date { Faker::Date.between(from: 6.months.ago, to: 1.week.ago) }
      end_date { start_date + rand(1..5).days }
    end
  end
end