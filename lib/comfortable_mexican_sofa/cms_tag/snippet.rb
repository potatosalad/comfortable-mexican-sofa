class CmsTag::Snippet
  include CmsTag
  include CmsTagResource

  set_cms_tag_class CmsSnippet

  def identifier
    "#{self.class.name.underscore}_#{self.resource.slug}"
  end
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:snippet:(#{label})\s*\}\}/
  end
end