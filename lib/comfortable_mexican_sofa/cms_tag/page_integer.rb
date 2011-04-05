class CmsTag::PageInteger
  include CmsTag
  include CmsTagResource
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:page:(#{label}):integer\s*\}\}/
  end
end