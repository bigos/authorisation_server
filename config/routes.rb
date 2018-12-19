Rails.application.routes.draw do
  use_doorkeeper
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/me' => 'application#me'

  root to: 'doorkeeper/applications#index'
end
