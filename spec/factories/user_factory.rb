FactoryBot.define do
  factory :user do
    login { Faker::Internet.username(separators: %w(_ -)) }
  end
end