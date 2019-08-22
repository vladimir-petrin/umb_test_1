class PostersQuery < DryService
  option :logins, [proc(&:to_s)]

  def call
    Post.joins(:user)
        .where('users.login' => logins)
        .group('posts.author_ip')
        .pluck('posts.author_ip', 'JSON_AGG(users.login)')
        .map { |poster_info| [poster_info[0].to_s, poster_info[1]] }
  end
end
