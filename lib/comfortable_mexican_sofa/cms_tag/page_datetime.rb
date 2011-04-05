class CmsTag::PageDateTime
  include CmsTag
  include CmsTagResource
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:page:(#{label}):datetime\s*\}\}/
  end
end