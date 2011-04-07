class CmsTag::FieldText
  include CmsTag
  include CmsTagResource
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:field:(#{label}):?(?:text)?\s*?\}\}/
  end
  
  def render
    ''
  end
  
end