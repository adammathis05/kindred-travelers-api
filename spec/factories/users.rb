FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    sequence(:email) { |n| "#{first_name.downcase}.#{last_name.downcase}#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
    admin { false }
    tribe

    # Traits for different types of users
    trait :admin do
      admin { true }
    end

    trait :with_common_names do
      first_name { ['Alice', 'Bob', 'Carol', 'David', 'Emma', 'Frank', 'Grace', 'Henry'].sample }
      last_name { ['Johnson', 'Smith', 'Davis', 'Wilson', 'Brown', 'Miller', 'Garcia', 'Lee'].sample }
    end

    trait :traveler_enthusiast do
      first_name { ['Marco', 'Stella', 'Atlas', 'Journey', 'Sage', 'River', 'Sky', 'Phoenix'].sample }
    end

    # After creating user, you can optionally add some activity
    trait :active_user do
      after(:create) do |user|
        # Create some reservations and vision board items for this user
        FactoryBot.create_list(:reservation, rand(1..3), user: user, tribe: user.tribe)
        FactoryBot.create_list(:vision_board_item, rand(2..5), user: user, tribe: user.tribe)
      end
    end

    trait :minimal_activity do
      after(:create) do |user|
        # Create minimal activity
        FactoryBot.create(:reservation, user: user, tribe: user.tribe)
        FactoryBot.create(:vision_board_item, user: user, tribe: user.tribe)
      end
    end

    # Factory for creating tribe admin (first user of a tribe)
    factory :tribe_admin, traits: [:admin] do
      after(:build) do |user|
        # Ensure this user is the first admin of their tribe
        user.tribe.users.clear if user.tribe.persisted?
      end
    end
  end
end