FactoryBot.define do
  factory :score do
    post { create(:post) }
    value { rand(1..5) }
  end
end