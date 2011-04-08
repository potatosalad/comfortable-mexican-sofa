require File.expand_path('../../test_helper', File.dirname(__FILE__))

class Jangle::PagesControllerTest < ActionController::TestCase
  
  def test_get_index
    get :index
    assert_response :success
    assert assigns(:jangle_pages)
    assert_template :index
  end
  
  def test_get_index_with_no_pages
    Jangle::Page.delete_all
    get :index
    assert_response :redirect
    assert_redirected_to :action => :new
  end
  
  def test_get_new
    get :new
    assert_response :success
    assert assigns(:jangle_page)
    assert_equal jangle_layouts(:default), assigns(:jangle_page).jangle_layout
    
    assert_template :new
    assert_select 'form[action=/cms-admin/pages]'
  end
  
  def test_get_new_with_field_datetime
    jangle_layouts(:default).update_attribute(:content, '{{cms:field:test_label:datetime}}')
    get :new
    assert_select "input[type='datetime'][name='jangle_page[jangle_blocks_attributes][][content]']"
    assert_select "input[type='hidden'][name='jangle_page[jangle_blocks_attributes][][label]'][value='test_label']"
  end
  
  def test_get_new_with_field_integer
    jangle_layouts(:default).update_attribute(:content, '{{cms:field:test_label:integer}}')
    get :new
    assert_select "input[type='number'][name='jangle_page[jangle_blocks_attributes][][content]']"
    assert_select "input[type='hidden'][name='jangle_page[jangle_blocks_attributes][][label]'][value='test_label']"
  end
  
  def test_get_new_with_field_string
    jangle_layouts(:default).update_attribute(:content, '{{cms:field:test_label}}')
    get :new
    assert_select "input[type='text'][name='jangle_page[jangle_blocks_attributes][][content]']"
    assert_select "input[type='hidden'][name='jangle_page[jangle_blocks_attributes][][label]'][value='test_label']"
  end
  
  def test_get_new_with_field_text
    jangle_layouts(:default).update_attribute(:content, '{{cms:field:test_label:text}}')
    get :new
    assert_select "textarea[name='jangle_page[jangle_blocks_attributes][][content]']"
    assert_select "input[type='hidden'][name='jangle_page[jangle_blocks_attributes][][label]'][value='test_label']"
  end
  
  def test_get_new_with_page_datetime
    jangle_layouts(:default).update_attribute(:content, '{{cms:page:test_label:datetime}}')
    get :new
    assert_select "input[type='datetime'][name='jangle_page[jangle_blocks_attributes][][content]']"
    assert_select "input[type='hidden'][name='jangle_page[jangle_blocks_attributes][][label]'][value='test_label']"
  end
  
  def test_get_new_with_page_integer
    jangle_layouts(:default).update_attribute(:content, '{{cms:page:test_label:integer}}')
    get :new
    assert_select "input[type='number'][name='jangle_page[jangle_blocks_attributes][][content]']"
    assert_select "input[type='hidden'][name='jangle_page[jangle_blocks_attributes][][label]'][value='test_label']"
  end
  
  def test_get_new_with_page_string
    jangle_layouts(:default).update_attribute(:content, '{{cms:page:test_label:string}}')
    get :new
    assert_select "input[type='text'][name='jangle_page[jangle_blocks_attributes][][content]']"
    assert_select "input[type='hidden'][name='jangle_page[jangle_blocks_attributes][][label]'][value='test_label']"
  end
  
  def test_get_new_with_page_text
    jangle_layouts(:default).update_attribute(:content, '{{cms:page:test_label}}')
    get :new
    assert_select "textarea[name='jangle_page[jangle_blocks_attributes][][content]']"
    assert_select "input[type='hidden'][name='jangle_page[jangle_blocks_attributes][][label]'][value='test_label']"
  end
  
  def test_get_new_with_rich_page_text
    jangle_layouts(:default).update_attribute(:content, '{{cms:page:test_label:rich_text}}')
    get :new
    assert_select "textarea[name='jangle_page[jangle_blocks_attributes][][content]']"
    assert_select "input[type='hidden'][name='jangle_page[jangle_blocks_attributes][][label]'][value='test_label']"
  end
  
  def test_get_new_as_child_page
    get :new, :parent_id => jangle_pages(:default)
    assert_response :success
    assert assigns(:jangle_page)
    assert_equal jangle_pages(:default), assigns(:jangle_page).parent
    assert_template :new
  end
  
  def test_get_edit
    page = jangle_pages(:default)
    get :edit, :id => page
    assert_response :success
    assert assigns(:jangle_page)
    assert_template :edit
    assert_select "form[action=/cms-admin/pages/#{page.id}]"
    assert_select "input[name='jangle_page[jangle_blocks_attributes][][id]'][value='#{jangle_blocks(:default_field_text).id}']"
    assert_select "input[name='jangle_page[jangle_blocks_attributes][][id]'][value='#{jangle_blocks(:default_field_text).id}']"
  end
  
  def test_get_edit_failure
    get :edit, :id => 'not_found'
    assert_response :redirect
    assert_redirected_to :action => :index
    assert_equal 'Page not found', flash[:error]
  end
  
  def test_get_edit_with_blank_layout
    page = jangle_pages(:default)
    page.update_attribute(:jangle_layout_id, nil)
    get :edit, :id => page
    assert_response :success
    assert assigns(:jangle_page)
    assert assigns(:jangle_page).jangle_layout
  end
  
  def test_creation
    assert_difference 'Jangle::Page.count' do
      assert_difference 'Jangle::Block.count', 2 do
        post :create, :jangle_page => {
          :label          => 'Test Page',
          :slug           => 'test-page',
          :parent_id      => jangle_pages(:default).id,
          :jangle_layout_id  => jangle_layouts(:default).id,
          :jangle_blocks_attributes => [
            { :label    => 'default_page_text',
              :content  => 'content content' },
            { :label    => 'default_field_text',
              :content  => 'title content' }
          ]
        }
        assert_response :redirect
        page = Jangle::Page.last
        assert_equal jangle_sites(:default), page.jangle_site
        assert_redirected_to :action => :edit, :id => page
        assert_equal 'Page saved', flash[:notice]
      end
    end
  end
  
  def test_creation_failure
    assert_no_difference ['Jangle::Page.count', 'Jangle::Block.count'] do
      post :create, :jangle_page => {
        :jangle_layout_id  => jangle_layouts(:default).id,
        :jangle_blocks_attributes => [
          { :label    => 'default_page_text',
            :content  => 'content content' },
          { :label    => 'default_field_text',
            :content  => 'title content' }
        ]
      }
      assert_response :success
      page = assigns(:jangle_page)
      assert_equal 2, page.jangle_blocks.size
      assert_equal ['content content', 'title content'], page.jangle_blocks.collect{|b| b.content}
      assert_template :new
      assert_equal 'Failed to create page', flash[:error]
    end
  end
  
  def test_update
    page = jangle_pages(:default)
    assert_no_difference 'Jangle::Block.count' do
      put :update, :id => page, :jangle_page => {
        :label => 'Updated Label'
      }
      page.reload
      assert_response :redirect
      assert_redirected_to :action => :edit, :id => page
      assert_equal 'Page updated', flash[:notice]
      assert_equal 'Updated Label', page.label
    end
  end
  
  def test_update_with_layout_change
    page = jangle_pages(:default)
    assert_difference 'Jangle::Block.count', 1 do
      put :update, :id => page, :jangle_page => {
        :label => 'Updated Label',
        :jangle_layout_id => jangle_layouts(:nested).id,
        :jangle_blocks_attributes => [
          { :label    => 'content',
            :content  => 'new_page_text_content',
            :id       => jangle_blocks(:default_page_text).id },
          { :label    => 'header',
            :content  => 'new_page_string_content' }
        ]
      }
      page.reload
      assert_response :redirect
      assert_redirected_to :action => :edit, :id => page
      assert_equal 'Page updated', flash[:notice]
      assert_equal 'Updated Label', page.label
      assert_equal ['new_page_text_content', 'default_field_text_content', 'new_page_string_content'], page.jangle_blocks.collect{|b| b.content}
    end
  end
  
  def test_update_failure
    put :update, :id => jangle_pages(:default), :jangle_page => {
      :label => ''
    }
    assert_response :success
    assert_template :edit
    assert assigns(:jangle_page)
    assert_equal 'Failed to update page', flash[:error]
  end
  
  def test_destroy
    assert_difference 'Jangle::Page.count', -2 do
      assert_difference 'Jangle::Block.count', -2 do
        delete :destroy, :id => jangle_pages(:default)
        assert_response :redirect
        assert_redirected_to :action => :index
        assert_equal 'Page deleted', flash[:notice]
      end
    end
  end
  
  def test_get_form_blocks
    xhr :get, :form_blocks, :id => jangle_pages(:default), :layout_id => jangle_layouts(:nested).id
    assert_response :success
    assert assigns(:jangle_page)
    assert_equal 2, assigns(:jangle_page).cms_tags.size
    assert_template :form_blocks
    
    xhr :get, :form_blocks, :id => jangle_pages(:default), :layout_id => jangle_layouts(:default).id
    assert_response :success
    assert assigns(:jangle_page)
    assert_equal 4, assigns(:jangle_page).cms_tags.size
    assert_template :form_blocks
  end
  
  def test_get_form_blocks_for_new_page
    xhr :get, :form_blocks, :id => 0, :layout_id => jangle_layouts(:default).id
    assert_response :success
    assert assigns(:jangle_page)
    assert_equal 3, assigns(:jangle_page).cms_tags.size
    assert_template :form_blocks
  end
  
  def test_creation_preview
    assert_no_difference 'Jangle::Page.count' do
      post :create, :preview => 'Preview', :jangle_page => {
        :label          => 'Test Page',
        :slug           => 'test-page',
        :parent_id      => jangle_pages(:default).id,
        :jangle_layout_id  => jangle_layouts(:default).id,
        :jangle_blocks_attributes => [
          { :label    => 'default_page_text',
            :content  => 'preview content' }
        ]
      }
      assert_response :success
      assert_match /preview content/, response.body
    end
  end
  
  def test_update_preview
    page = jangle_pages(:default)
    assert_no_difference 'Jangle::Page.count' do
      put :update, :preview => 'Preview', :id => page, :jangle_page => {
        :label => 'Updated Label',
        :jangle_blocks_attributes => [
          { :label    => 'default_page_text',
            :content  => 'preview content',
            :id       => jangle_blocks(:default_page_text).id}
        ]
      }
      assert_response :success
      assert_match /preview content/, response.body
      page.reload
      assert_not_equal 'Updated Label', page.label
    end
  end
  
  def test_get_new_with_no_layout
    Jangle::Layout.destroy_all
    get :new
    assert_response :redirect
    assert_redirected_to new_jangle_layout_path
    assert_equal 'No Layouts found. Please create one.', flash[:error]
  end
  
  def test_get_edit_with_no_layout
    Jangle::Layout.destroy_all
    page = jangle_pages(:default)
    get :edit, :id => page
    assert_response :redirect
    assert_redirected_to new_jangle_layout_path
    assert_equal 'No Layouts found. Please create one.', flash[:error]
  end
  
  def test_get_toggle_branch
    page = jangle_pages(:default)
    get :toggle_branch, :id => page, :format => :js
    assert_response :success
    assert_equal [page.id.to_s], session[:jangle_page_tree]
    
    get :toggle_branch, :id => page, :format => :js
    assert_response :success
    assert_equal [], session[:jangle_page_tree]
  end
  
  def test_reorder
    page_one = jangle_pages(:child)
    page_two = jangle_sites(:default).jangle_pages.create!(
      :parent     => jangle_pages(:default),
      :jangle_layout => jangle_layouts(:default),
      :label      => 'test',
      :slug       => 'test'
    )
    assert_equal 0, page_one.position
    assert_equal 1, page_two.position
    
    post :reorder, :jangle_page => [page_two.id, page_one.id]
    assert_response :success
    page_one.reload
    page_two.reload
    
    assert_equal 1, page_one.position
    assert_equal 0, page_two.position
  end
  
end