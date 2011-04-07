class CmsTag::FieldInteger
  include CmsTag
  include CmsTagResource
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:field:(#{label}):integer\s*\}\}/
  end
  
  def render
    ''
  end
  
end