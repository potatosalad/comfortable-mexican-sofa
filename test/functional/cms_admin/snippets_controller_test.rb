require File.expand_path('../../test_helper', File.dirname(__FILE__))

class Jangle::SnippetsControllerTest < ActionController::TestCase

  def test_get_index
    get :index
    assert_response :success
    assert assigns(:jangle_snippets)
    assert_template :index
  end
  
  def test_get_index_with_no_snippets
    Jangle::Snippet.delete_all
    get :index
    assert_response :redirect
    assert_redirected_to :action => :new
  end
  
  def test_get_new
    get :new
    assert_response :success
    assert assigns(:jangle_snippet)
    assert_template :new
    assert_select 'form[action=/cms-admin/snippets]'
  end
  
  def test_get_edit
    snippet = jangle_snippets(:default)
    get :edit, :id => snippet
    assert_response :success
    assert assigns(:jangle_snippet)
    assert_template :edit
    assert_select "form[action=/cms-admin/snippets/#{snippet.id}]"
  end
  
  def test_get_edit_failure
    get :edit, :id => 'not_found'
    assert_response :redirect
    assert_redirected_to :action => :index
    assert_equal 'Snippet not found', flash[:error]
  end
  
  def test_creation
    assert_difference 'Jangle::Snippet.count' do
      post :create, :jangle_snippet => {
        :label    => 'Test Snippet',
        :slug     => 'test-snippet',
        :content  => 'Test Content'
      }
      assert_response :redirect
      snippet = Jangle::Snippet.last
      assert_equal jangle_sites(:default), snippet.jangle_site
      assert_redirected_to :action => :edit, :id => snippet
      assert_equal 'Snippet created', flash[:notice]
    end
  end
  
  def test_creation_failure
    assert_no_difference 'Jangle::Snippet.count' do
      post :create, :jangle_snippet => { }
      assert_response :success
      assert_template :new
      assert_equal 'Failed to create snippet', flash[:error]
    end
  end
  
  def test_update
    snippet = jangle_snippets(:default)
    put :update, :id => snippet, :jangle_snippet => {
      :label    => 'New-Snippet',
      :content  => 'New Content'
    }
    assert_response :redirect
    assert_redirected_to :action => :edit, :id => snippet
    assert_equal 'Snippet updated', flash[:notice]
    snippet.reload
    assert_equal 'New-Snippet', snippet.label
    assert_equal 'New Content', snippet.content
  end
  
  def test_update_failure
    snippet = jangle_snippets(:default)
    put :update, :id => snippet, :jangle_snippet => {
      :label => ''
    }
    assert_response :success
    assert_template :edit
    snippet.reload
    assert_not_equal '', snippet.label
    assert_equal 'Failed to update snippet', flash[:error]
  end
  
  def test_destroy
    assert_difference 'Jangle::Snippet.count', -1 do
      delete :destroy, :id => jangle_snippets(:default)
      assert_response :redirect
      assert_redirected_to :action => :index
      assert_equal 'Snippet deleted', flash[:notice]
    end
  end
  
end