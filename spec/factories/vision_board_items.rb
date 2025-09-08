FactoryBot.define do
  factory :vision_board_item do
    title { "#{item_type.humanize}: #{Faker::Lorem.words(number: rand(2..4)).join(' ').titleize}" }
    description { Faker::Lorem.paragraph(sentence_count: rand(1..3)) }
    item_type { ['inspiration', 'activity', 'place', 'food', 'accommodation'].sample }
    priority { rand(1..5) }
    image_url { [Faker::Internet.url(host: 'images.unsplash.com'), nil].sample }
    link_url { [Faker::Internet.url, nil].sample }
    achieved { [true, false].sample }
    user
    tribe { user.tribe }

    # Specific item types with realistic content
    trait :inspiration do
      item_type { 'inspiration' }
      title { ['Sunset Photography', 'Cultural Immersion', 'Local Markets', 'Street Art Tour', 'Music Scene'].sample }
      description { "Capture the essence of #{user.tribe.destination} through this unique experience" }
    end

    trait :activity do
      item_type { 'activity' }
      title { ['Temple Hopping', 'Food Tours', 'Hiking Adventure', 'Museum Visits', 'Cooking Class'].sample }
      description { "Must-do activity while in #{user.tribe.destination.split(',').first}" }
    end

    trait :place do
      item_type { 'place' }
      title { ['Historic District', 'Famous Landmark', 'Hidden Gem', 'Scenic Viewpoint', 'Local Neighborhood'].sample }
      description { "Important place to visit in #{user.tribe.destination}" }
    end

    trait :food do
      item_type { 'food' }
      title { ['Local Street Food', 'Traditional Dish', 'Famous Restaurant', 'Food Market', 'Cooking Experience'].sample }
      description { "Taste the authentic flavors of #{user.tribe.destination.split(',').first}" }
    end

    trait :accommodation do
      item_type { 'accommodation' }
      title { ['Boutique Hotel', 'Traditional Inn', 'Unique Stay', 'Hostel Experience', 'Local B&B'].sample }
      description { "Special place to stay during our trip to #{user.tribe.destination}" }
    end

    trait :high_priority do
      priority { rand(4..5) }
    end

    trait :low_priority do
      priority { rand(1..2) }
    end

    trait :achieved do
      achieved { true }
    end

    trait :pending do
      achieved { false }
    end

    trait :with_image do
      image_url { "https://images.unsplash.com/photo-#{rand(1500000000..1600000000)}-#{Faker::Alphanumeric.alphanumeric(number: 10)}" }
    end

    trait :with_link do
      link_url { Faker::Internet.url(host: ['tripadvisor.com', 'lonelyplanet.com', 'timeout.com'].sample) }
    end

    trait :complete_item do
      with_image
      with_link
      description { Faker::Lorem.paragraph(sentence_count: 3) }
      high_priority
    end

    # Location-specific items
    trait :tokyo_item do
      title { ['Visit Senso-ji Temple', 'Try Authentic Ramen', 'Cherry Blossom Viewing', 'Robot Restaurant', 'Tsukiji Fish Market'].sample }
      description { "Experience the unique culture and attractions of Tokyo" }
    end

    trait :europe_item do
      title { ['Visit the Louvre', 'Oktoberfest Experience', 'Castle Stay', 'Northern Lights', 'Italian Cooking Class'].sample }
      description { "Must-do European experience during our backpacking adventure" }
    end

    trait :bali_item do
      title { ['Sunrise at Mount Batur', 'Temple Tour', 'Beach Day', 'Yoga Retreat', 'Traditional Dance Show'].sample }
      description { "Tropical paradise experience in beautiful Bali" }
    end
  end
end