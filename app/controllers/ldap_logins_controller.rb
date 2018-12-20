class LdapLoginsController < Doorkeeper::AuthorizationsController
  # finding that took couple of hours
  before_action :authenticate_resource_owner!, except: [:new, :create]
  respond_to :json, only: :create

  def new
  end

  def create
    login = params['login']
    pass  = params['pass']

    require 'net/ldap'
    authenticated = authenticate_ldap(login, pass)

    @user = User.where(email: authenticated).first
    @user = User.new(email: authenticated, password: 'not-applicable') unless @user
    @user.save
    session[:user_id] = @user.id

    if authenticated
      puts "authenticated - please respond with good json"

      if params[:client_id]
        client_app = Doorkeeper::Application.where(uid: params[:client_id]).first
        if client_app
          redirect_to (client_app.redirect_uri +
                       '?' +
                       { provider: 'authoritarian',
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
