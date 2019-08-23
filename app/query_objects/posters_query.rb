class PostersQuery < DryService
  option :logins, [proc(&:to_s)]

  def call
    Post.joins(:user)
        .where('users.login' => logins)
        .group('posts.author_ip')
        .pluck('posts.author_ip', 'JSON_AGG(users.login)')
        .map do |poster_info|
          {
            ip: poster_info[0].to_s,
            users: poster_info[1]
          }
        end
  end
end
