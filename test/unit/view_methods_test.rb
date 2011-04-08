require File.expand_path('../test_helper', File.dirname(__FILE__))

class ViewMethodsTest < ActiveSupport::TestCase
  
  include Jangle::ViewMethods
  
  def test_jangle_snippet_content
    assert_equal 'default_snippet_content', jangle_snippet_content('default')
    assert_equal '', jangle_snippet_content('not_found')
  end
  
  def test_jangle_page_content
    assert_equal 'default_field_text_content', jangle_page_content('default_field_text', jangle_pages(:default))
    assert_equal '', jangle_page_content('default_field_text')
    @jangle_page = jangle_pages(:default)
    assert_equal 'default_field_text_content', jangle_page_content('default_field_text')
    assert_equal '', jangle_page_content('not_found')
    @jangle_page = nil
  end
  
end