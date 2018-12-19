Rails.application.routes.draw do
  use_doorkeeper
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/me' => 'application#me'

  namespace :api do
    namespace :v1 do
      # another api routes
      get '/me' => "credentials#me"
    end
  end

  root to: 'doorkeeper/applications#index'
end
