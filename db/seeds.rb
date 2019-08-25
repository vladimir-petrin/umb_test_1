require 'faker'

usernames = (1..100).map { Faker::Internet.username(separators: %w(_ -)) }
ips = (1..50).map { Faker::Internet.ip_v4_address }

200_000.times do
  post_params = {
    login: usernames.sample,
    title: Faker::Lorem.sentence,
    content: Faker::Lorem.paragraph,
    author_ip: ips.sample
  }

  post = CreatePostService.call(post_params)

  rand(10).times do
    CreateScoreService.call(post, value: rand(1..5))
  end
end