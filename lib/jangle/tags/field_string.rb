class CmsTag::FieldString
  include CmsTag
  include CmsTagResource
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:field:(#{label}):?(?:string)?\s*\}\}/
  end
  
  def render
    ''
  end
  
end