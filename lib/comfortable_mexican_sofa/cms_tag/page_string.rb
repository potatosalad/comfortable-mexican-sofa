class CmsTag::PageString
  include CmsTag
  include CmsTagResource
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:page:(#{label}):string\s*\}\}/
  end
end