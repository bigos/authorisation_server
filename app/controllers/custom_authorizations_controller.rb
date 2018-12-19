# we did override the original routes, so we need to inherit from the original controller
# the route methods not seen here will be implemented by the parent class
class CustomAuthorizationsController < Doorkeeper::AuthorizationsController
  def new
    # code copied from the parent class
    if pre_auth.authorizable?
      render_success
    else
      render_error
    end
  end

  private

  def render_success
    if skip_authorization? || matching_token?
      redirect_or_render authorize_response
    elsif Doorkeeper.configuration.api_only
      render json: pre_auth
    else
      # one day we can render :ldap_login here
      render :new
    end
  end

end
