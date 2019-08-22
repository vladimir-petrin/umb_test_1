FactoryBot.define do
  factory :post do
    user { create(:user) }
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    author_ip { Faker::Internet.ip_v4_address }
  end
end