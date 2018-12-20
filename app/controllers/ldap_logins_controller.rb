class LdapLoginsController < Doorkeeper::AuthorizationsController
  # ApplicationController
  before_action :authenticate_resource_owner!, except: [:new, :create]
  def new
  end

  def create
    byebug
    2==2
    nil

    u = User.new(email: 'test@test.com', password: 'password')
    u.save
    session[:user_id] = u.id
    # we should have User.last so the authorisation should work
    # redirect_to oauth_authorization_path
  end
end
