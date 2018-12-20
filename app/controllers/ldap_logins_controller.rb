class LdapLoginsController < Doorkeeper::AuthorizationsController
  # finding that took couple of hours
  before_action :authenticate_resource_owner!, except: [:new, :create]

  def new
    if pre_auth.authorizable?
      render_success
    else
      render_error
    end
  end

  def create
    byebug
    2==2
    nil

    @user = User.new(email: 'test@test.com', password: 'password')
    @user.save!
    session[:user_id] = @user.id

    # if pre_auth.authorizable?
    #   render_success
    # else
    #   render_error
    # end

    redirect_or_render authorize_response
  end
end
