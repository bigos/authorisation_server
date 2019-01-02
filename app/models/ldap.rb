require 'net/ldap'

class Ldap
  def initialize
  end

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
