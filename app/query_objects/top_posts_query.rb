class TopPostsQuery < DryService
  option :limit, default: proc { 100 }

  def call
    Post.joins(:avg_score)
        .order('avg_scores.avg_value' => :desc)
        .limit(limit)
        .map do |post|
      post.as_json(only: %i[title content])
    end
  end
end
