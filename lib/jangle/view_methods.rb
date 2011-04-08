module Jangle::ViewMethods
  # Wrapper around CmsFormBuilder
  def cms_form_for(record_or_name_or_array, *args, &proc)
    options = args.extract_options!
    form_for(record_or_name_or_array, *(args << options.merge(:builder => Jangle::FormBuilder)), &proc)
  end
  
  # Wrapper for <span>
  def span_tag(*args)
    content_tag(:span, *args)
  end
  
  # Rails 3.0 doesn't have this helper defined
  def datetime_field_tag(name, value = nil, options = {})
    text_field_tag(name, value, options.stringify_keys.update('type' => 'datetime'))
  end
  
  # Injects some content somewhere inside cms admin area
  def cms_hook(name, options = {})
    Jangle::ViewHooks.render(name, self, options)
  end
  
  # Content of a snippet. Example:
  #   jangle_snippet_content(:my_snippet)
  def jangle_snippet_content(snippet_slug)
    return '' unless snippet = Jangle::Snippet.find_by_slug(snippet_slug)
    snippet.content.to_s.html_safe
  end
  
  # Content of a page block. This is how you get content from page:field
  # Example:
  #   jangle_page_content(:left_column, Jangle::Page.first)
  #   jangle_page_content(:left_column) # if @jangle_page is present
  def jangle_page_content(block_label, page = nil)
    return '' unless page ||= @jangle_page
    return '' unless block = page.jangle_blocks.find_by_label(block_label)
    block.content.to_s.html_safe
  end
end

ActionView::Base.send :include, Jangle::ViewMethods

ActionView::Helpers::AssetTagHelper.register_javascript_expansion :cms => [
  'comfortable_mexican_sofa/jquery',
  'comfortable_mexican_sofa/jquery-ui/jquery-ui',
  'comfortable_mexican_sofa/rails',
  'comfortable_mexican_sofa/plupload/plupload.min',
  'comfortable_mexican_sofa/plupload/plupload.html5.min',
  'comfortable_mexican_sofa/codemirror/codemirror.js',
  'comfortable_mexican_sofa/cms'
]
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :tiny_mce => [
  'comfortable_mexican_sofa/tiny_mce/tiny_mce',
  'comfortable_mexican_sofa/tiny_mce/jquery.tinymce'
]

ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :cms => [
  'comfortable_mexican_sofa/reset',
  'comfortable_mexican_sofa/structure',
  'comfortable_mexican_sofa/typography',
  'comfortable_mexican_sofa/form',
  'comfortable_mexican_sofa/content',
  '/javascripts/comfortable_mexican_sofa/jquery-ui/jquery-ui'
]