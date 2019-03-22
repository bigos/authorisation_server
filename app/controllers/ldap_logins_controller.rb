class LdapLoginsController < Doorkeeper::AuthorizationsController
  # ApplicationController

  # finding that took couple of hours
  before_action :authenticate_resource_owner!, except: [:new, :create]
  respond_to :json, only: :create

  def new
  end

  def create
    login = params['login']
    password  = params['password']

    authenticated = Ldap.new.authenticate_ldap(login, password).to_s.downcase

    @user = User.where(email: authenticated).first
    unless @user
      # TODO
      # we need to create admin users from the console, because all other users
      # passwords are are set to the same string, random hash would be better
      @user = User.new(email: authenticated, password: 'not-applicable')
      @user.save
    end
    session[:user_id] = @user.id

    logger.info " processing authentication results #{authenticated.inspect}"

    unless authenticated.blank?
      if params[:client_id]
        client_app = Doorkeeper::Application.where(uid: params[:client_id]).first

        logger.info " processing authentication before if #{client_app.inspect}"

        if client_app

          # taken from Doorkeeper model code
          #
          # Looking for not expired AccessToken record with a matching set of
          # scopes that belongs to specific Application and Resource Owner.
          # If it doesn't exists - then creates it.
          #
          # @param application [Doorkeeper::Application]
          #   Application instance
          # @param resource_owner_id [ActiveRecord::Base, Integer]
          #   Resource Owner model instance or it's ID
          # @param scopes [#to_s]
          #   set of scopes (any object that responds to `#to_s`)
          # @param expires_in [Integer]
          #   token lifetime in seconds
          # @param use_refresh_token [Boolean]
          #   whether to use the refresh token
          #
          # @return [Doorkeeper::AccessToken] existing record or a new one
          #

          code = Doorkeeper::AccessToken.find_or_create_for(client_app,
                                                            @user.id,
                                                            nil,
                                                            7200,
                                                            true )

          grant = Doorkeeper::AccessGrant.create(resource_owner_id: @user.id,
                                                 application_id: client_app.id,
                                                 token: code.token,
                                                 expires_in: 600,
                                                 redirect_uri: client_app.redirect_uri,
                                                 scopes: nil)
          # why do I have to update the token?
          grant.update(token: code.token)

          redirect_to (client_app.redirect_uri +
                       '?' +
                       { code: code.token,
                         state: params[:state]
                       }.to_query)
        else
          # no client app
          # there is probably a problem with the secrets configuration
          super
        end
      else
        # no action dispatch cookie
        super
      end
    else
      # not authenticated
      super
    end
  end
end
