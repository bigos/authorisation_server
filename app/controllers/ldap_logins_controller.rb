class LdapLoginsController < Doorkeeper::AuthorizationsController
      # ApplicationController
  def new
    byebug
    1==1

    nil
  end

  def create
    byebug
    2==2
    nil

    u = User.new(email: 'test@test.com', password: 'password')
    u.save
    # we should have User.last so the authorisation should work
    redirect_to oauth_authorization_path
  end
end
