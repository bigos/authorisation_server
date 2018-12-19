# we did override the original routes, so we need to inherit from the original controller
# the route methods not seen here will be implemented by the parent class
class CustomAuthorizationsController < Doorkeeper::AuthorizationsController

  def new
    byebug
    1==1

    super
  end

  def create
    byebug
    2==2

    super
  end
end
