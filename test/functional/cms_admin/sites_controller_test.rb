require File.expand_path('../../test_helper', File.dirname(__FILE__))

class Jangle::SitesControllerTest < ActionController::TestCase
  
  def test_get_index
    get :index
    assert_response :success
    assert assigns(:jangle_sites)
    assert_template :index
  end
  
  def test_get_index_with_no_sites
    Jangle::Site.delete_all
    get :index
    assert_response :redirect
    assert_redirected_to :action => :new
  end
  
  def test_get_new
    get :new
    assert_response :success
    assert assigns(:jangle_site)
    assert_equal 'test.host', assigns(:jangle_site).hostname
    assert_template :new
    assert_select 'form[action=/cms-admin/sites]'
  end
  
  def test_get_edit
    site = jangle_sites(:default)
    get :edit, :id => site
    assert_response :success
    assert assigns(:jangle_site)
    assert_template :edit
    assert_select "form[action=/cms-admin/sites/#{site.id}]"
  end
  
  def test_get_edit_failure
    get :edit, :id => 'not_found'
    assert_response :redirect
    assert_redirected_to :action => :index
    assert_equal 'Site not found', flash[:error]
  end
  
  def test_creation
    assert_difference 'Jangle::Site.count' do
      post :create, :jangle_site => {
        :label    => 'Test Site',
        :hostname => 'test.site.local'
      }
      assert_response :redirect
      assert_redirected_to :action => :edit, :id => Jangle::Site.last
      assert_equal 'Site created', flash[:notice]
    end
  end
  
  def test_creation_failure
    assert_no_difference 'Jangle::Site.count' do
      post :create, :jangle_site => { }
      assert_response :success
      assert_template :new
      assert_equal 'Failed to create site', flash[:error]
    end
  end
  
  def test_update
    site = jangle_sites(:default)
    put :update, :id => site, :jangle_site => {
      :label    => 'New Site',
      :hostname => 'new.site.local'
    }
    assert_response :redirect
    assert_redirected_to :action => :edit, :id => site
    assert_equal 'Site updated', flash[:notice]
    site.reload
    assert_equal 'New Site', site.label
    assert_equal 'new.site.local', site.hostname
  end
  
  def test_update_failure
    site = jangle_sites(:default)
    put :update, :id => site, :jangle_site => {
      :label => ''
    }
    assert_response :success
    assert_template :edit
    site.reload
    assert_not_equal '', site.label
    assert_equal 'Failed to update site', flash[:error]
  end
  
  def test_destroy
    assert_difference 'Jangle::Site.count', -1 do
      delete :destroy, :id => jangle_sites(:default)
      assert_response :redirect
      assert_redirected_to :action => :index
      assert_equal 'Site deleted', flash[:notice]
    end
  end
end