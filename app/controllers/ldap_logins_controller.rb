class LdapLoginsController < Doorkeeper::AuthorizationsController
  # ApplicationController

  # finding that took couple of hours
  before_action :authenticate_resource_owner!, except: [:new, :create]
  respond_to :json, only: :create

  def new
  end

  def create
    require 'net/ldap'
    login = params['login']
    password  = params['password']

    # email of authenticated user or empty string
    authenticated = authenticate_ldap(login, password).to_s.downcase

    @user = User.where(email: authenticated).first
    unless @user
      # TODO
      # we need to create admin users from the console, because all other users
      # passwords are are set to the same string, random hash would be better
      @user = User.new(email: authenticated, password: 'not-applicable')
      @user.save
    end
    session[:user_id] = @user.id

    unless authenticated.blank?
      if params[:client_id]
        client_app = Doorkeeper::Application.where(uid: params[:client_id]).first
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

  private

  def get_ldap_response(ldap)
    msg = "Response Code: #{ ldap.get_operation_result.code }, Message: #{ ldap.get_operation_result.message }"

    raise msg unless ldap.get_operation_result.code == 0
  end

  def authenticate_ldap(login, password)
    raise ArgumentError, 'password is nil' if login.blank? or password.blank?

    require 'net/ldap'
    ldap      = Net::LDAP.new
    ldap.host = 'neptune' # LDAP_CONFIG['host']
    ldap.port = 389 # LDAP_CONFIG['port']
    ldap.auth "uid=#{login},ou=People,dc=salltd,dc=co,dc=uk", password

    bound = ldap.bind
    if bound
      base = "uid=#{login}, ou=People,dc=salltd, dc=co, dc=uk"
      result_attrs = ['sAMAccountName', 'displayName', 'mail']
      found = ldap.search(base: base,
                          return_results: true,
                          attributes: result_attrs)
      get_ldap_response(ldap) # raise error if no success

      found.first[:mail].first
    end
  end
end
