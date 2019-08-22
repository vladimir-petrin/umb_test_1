class CreatePostService < DryService
  option :login, proc(&:to_s)
  option :title, proc(&:to_s)
  option :content, proc(&:to_s)
  option :author_ip, ->(val) { IPAddr.new val }

  def call
    user.posts.create(title: title, content: content, author_ip: author_ip)
  end

  private

  def user
    User.find_by(login: login) || User.create!(login: login)
  end
end
