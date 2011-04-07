require File.expand_path('../test_helper', File.dirname(__FILE__))

class AuthenticationTest < ActionDispatch::IntegrationTest
  
  def test_get_with_unauthorized_access
    assert_equal 'Jangle::HttpAuth', Jangle.config.authentication
    get '/cms-admin/pages'
    assert_response :unauthorized
    get '/'
    assert_response :success
  end
  
  def test_get_with_authorized_access
    http_auth :get, '/cms-admin/pages'
    assert_response :success
  end
  
  def test_get_with_changed_default_config
    assert_equal 'Jangle::HttpAuth', Jangle.config.authentication
    Jangle::HttpAuth.username = 'newuser'
    Jangle::HttpAuth.password = 'newpass'
    http_auth :get, '/cms-admin/pages'
    assert_response :unauthorized
    http_auth :get, '/cms-admin/pages', {}, 'newuser', 'newpass'
    assert_response :success
  end
end