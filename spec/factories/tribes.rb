FactoryBot.define do
  factory :tribe do
    sequence(:name) { |n| "#{Faker::Address.city} #{['Adventure', 'Explorer', 'Wanderer', 'Journey'].sample} #{n}" }
    description { "A group of #{Faker::Number.between(from: 2, to: 8)} friends exploring #{destination} together" }
    destination { "#{Faker::Address.city}, #{Faker::Address.country}" }
    start_date { Faker::Date.between(from: 1.month.from_now, to: 6.months.from_now) }
    end_date { start_date + Faker::Number.between(from: 3, to: 21).days }
    total_budget { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
    current_expenses { 0.0 }

    # Traits for different types of trips
    trait :budget_trip do
      total_budget { Faker::Number.between(from: 500, to: 1500) }
    end

    trait :luxury_trip do
      total_budget { Faker::Number.between(from: 5000, to: 15000) }
    end

    trait :backpacking do
      name { "#{destination.split(',').first} Backpackers" }
      description { "Budget-friendly backpacking adventure through #{destination}" }
      total_budget { Faker::Number.between(from: 800, to: 2000) }
    end

    trait :family_trip do
      name { "#{destination.split(',').first} Family Adventure" }
      description { "Family vacation to create lasting memories in #{destination}" }
      total_budget { Faker::Number.between(from: 3000, to: 8000) }
    end

    trait :group_adventure do
      name { "#{destination.split(',').first} Squad" }
      description { "Friends' trip to explore and have fun in #{destination}" }
      total_budget { Faker::Number.between(from: 2000, to: 5000) }
    end

    # Popular destinations
    trait :tokyo_trip do
      destination { "Tokyo, Japan" }
      name { "Tokyo Adventure Squad" }
      description { "Exploring the vibrant culture, amazing food, and modern wonders of Tokyo" }
    end

    trait :europe_trip do
      destination { "Multiple European Cities" }
      name { "European Explorer" }
      description { "Multi-city European adventure through historic cities and beautiful landscapes" }
    end

    trait :bali_trip do
      destination { "Bali, Indonesia" }
      name { "Bali Bliss Tribe" }
      description { "Tropical paradise adventure with beaches, culture, and relaxation" }
    end
  end
end