class CmsTag::TemplateRichText
  include CmsTag
  include CmsTagResource

  set_cms_tag_class_name 'Jangle::WidgetBlock'

  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:template:(#{label}):rich_text\s*\}\}/
  end
end