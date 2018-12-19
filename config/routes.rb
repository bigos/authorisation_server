Rails.application.routes.draw do

  # we use customised controller, instead of the controller provided by the gem
  use_doorkeeper do
    controllers authorizations: 'custom_authorizations'
  end

  resource :ldap_login, only: [:new, :create]

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      # another api routes
      get '/me' => "credentials#me"
    end
  end

  root to: 'doorkeeper/applications#index'
end
