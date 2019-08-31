FactoryBot.define do
  factory :avg_score do
    post { create(:post) }
    avg_value { rand(100..500) }
  end
end