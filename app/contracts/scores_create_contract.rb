class ScoresCreateContract < Dry::Validation::Contract
  params do
    required(:value).value(:integer, gteq?: 1, lteq?: 5)
  end
end
