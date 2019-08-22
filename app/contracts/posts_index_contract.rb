class PostsIndexContract < Dry::Validation::Contract
  params do
    optional(:limit).filled(:integer, gt?: 0)
  end
end
