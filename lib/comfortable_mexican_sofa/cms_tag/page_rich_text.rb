class CmsTag::PageRichText
  include CmsTag
  include CmsTagResource

  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:page:(#{label}):rich_text\s*\}\}/
  end
end