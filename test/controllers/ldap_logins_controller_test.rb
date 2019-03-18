require 'test_helper'

class LdapLoginsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get ldap_logins_new_url
    assert_response :success
  end

  test "should get create" do
    get ldap_logins_create_url
    assert_response :success
  end

end
