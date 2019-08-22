class CreateScoreService < DryService
  param :post, model: Post
  option :value, proc(&:to_i)

  def call
    post.scores.create(value: value)
  end
end
