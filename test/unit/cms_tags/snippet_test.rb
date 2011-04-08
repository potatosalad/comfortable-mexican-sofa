require File.expand_path('../../test_helper', File.dirname(__FILE__))

class SnippetTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    assert tag = CmsTag::Snippet.initialize_tag(jangle_pages(:default), '{{ cms:snippet:label }}')
    assert_equal 'label', tag.slug
    assert tag = CmsTag::Snippet.initialize_tag(jangle_pages(:default), '{{cms:snippet:label}}')
    assert_equal 'label', tag.slug
    assert tag = CmsTag::Snippet.initialize_tag(jangle_pages(:default), '{{cms:snippet:dash-label}}')
    assert_equal 'dash-label', tag.slug
  end
  
  def test_initialize_tag_failure
    [
      '{{cms:snippet}}',
      '{{cms:not_snippet:label}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil CmsTag::Snippet.initialize_tag(jangle_pages(:default), tag_signature)
    end
  end
  
  def test_content_and_render
    tag = CmsTag::Snippet.initialize_tag(jangle_pages(:default), '{{cms:snippet:default}}')
    assert_equal 'default_snippet_content', tag.content
    assert_equal 'default_snippet_content', tag.render
    
    tag = CmsTag::Snippet.initialize_tag(jangle_pages(:default), "{{cms:snippet:doesnot_exist}}")
    assert_equal nil, tag.content
    assert_equal '', tag.render
  end
end