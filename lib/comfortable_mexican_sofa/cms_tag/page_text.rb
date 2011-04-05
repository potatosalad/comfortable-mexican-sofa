class CmsTag::PageText
  include CmsTag
  include CmsTagResource

  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:page:(#{label}):?(?:text)?\s*\}\}/
  end
end