class CmsTag::Widget
  include CmsTag
  include CmsTagResource

  set_cms_tag_class_name 'Jangle::Widget'

  def identifier
    "#{self.class.name.underscore}_#{self.resource.slug}"
  end
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:widget:(#{label})\s*\}\}/
  end
end