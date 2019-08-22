class TopPostsQuery < DryService
  option :limit, default: proc { 100 }

  def call
    Post.order(avg_score: :desc).limit(limit).map { |post| post.as_json(only: %i[title content]) }
  end
end
