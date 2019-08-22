class ServicePostersContract < Dry::Validation::Contract
  schema do
    required(:logins).array(:str?, :filled?)
  end

  rule(:logins) do
    unique_logins = value.uniq
    found_logins = User.where(login: unique_logins).pluck(:login)

    unless unique_logins.size == found_logins.size
      not_found_logins = (unique_logins - found_logins)

      key.failure("users with logins: #{not_found_logins} not found")
    end
  end
end
