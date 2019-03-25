class LdapLoginsController < Doorkeeper::AuthorizationsController
  # ApplicationController

  # finding that took couple of hours
  before_action :authenticate_resource_owner!, except: [:new, :create]
  respond_to :json, only: :create

  def new
  end

  # if you get errors here it might be because the client doesn't have
  # the correct credentials, in one case copying the credentials in
  # config/secrets.yml to the production section has fixed the problem
  def create
    login = params['login']
    password  = params['password']
    client_id = params[:client_id]

    authenticated = Ldap.new.authenticate_ldap(login, password).to_s.downcase

    @user = User.where(email: authenticated).first
    unless @user
      # password is not used because we use OAUTH authentication
      # but still we set it on semi-random hash
      @user = User.new(email: authenticated,
                       password: Digest::MD5.new.update(Time.now.ctime).hexdigest)
      @user.save
    end

    session[:user_id] = @user.id

    unless authenticated.blank?
      if client_id
        client_app = Doorkeeper::Application.where(uid: client_id).first

        if client_app
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
          logger.error "problem with the client app credentials"
          super
        end
      else
        # no action dispatch cookie
        logger.error "client_id was blank #{client_id}"
        super
      end
    else
      logger.info "authentication failed for: #{login}"
      # not authenticated
      super
    end
  end
end
