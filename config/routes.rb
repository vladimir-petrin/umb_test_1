Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :posts, only: %i[index create] do
        resources :scores, only: %i[create]
      end

      namespace :service do
        get 'posters'
      end
    end
  end
end
