require File.expand_path('../test_helper', File.dirname(__FILE__))

class SitesTest < ActionDispatch::IntegrationTest
  
  def test_get_admin
    http_auth :get, jangle_pages_path
    assert_response :success
  end
  
  def test_get_admin_with_no_site
    Jangle::Site.delete_all
    assert_difference 'Jangle::Site.count' do
      http_auth :get, jangle_pages_path
      assert_response :redirect
      assert_redirected_to new_jangle_page_path
      site = Jangle::Site.first
      assert_equal 'test.host', site.hostname
      assert_equal 'Default Site', site.label
    end
  end
  
  def test_get_admin_with_wrong_site
    site = cms_sites(:default)
    site.update_attribute(:hostname, 'remote.host')
    assert_no_difference 'Jangle::Site.count' do
      http_auth :get, jangle_pages_path
      assert_response :success
      site.reload
      assert_equal 'test.host', site.hostname
    end
  end
  
  def test_get_admin_with_two_wrong_sites
    Jangle::Site.delete_all
    Jangle::Site.create!(:label => 'Site1', :hostname => 'site1.host')
    Jangle::Site.create!(:label => 'Site2', :hostname => 'site2.host')
    assert_no_difference 'Jangle::Site.count' do
      http_auth :get, jangle_pages_path
      assert_response :redirect
      assert_redirected_to jangle_sites_path
      assert_equal 'No Site defined for this hostname. Create it now.', flash[:error]
    end
  end
  
  def test_get_admin_with_no_site_and_no_auto_manage
    Jangle.config.auto_manage_sites = false
    Jangle::Site.delete_all
    assert_no_difference 'Jangle::Site.count' do
      http_auth :get, jangle_pages_path
      assert_response :redirect
      assert_redirected_to jangle_sites_path
      assert_equal 'No Site defined for this hostname. Create it now.', flash[:error]
    end
  end
  
  def test_get_public_page_for_non_existent_site
    host! 'bogus.host'
    get '/'
    assert_response 404
    assert_equal 'Site Not Found', response.body
  end
  
end