class Jangle::Template
  include Jangle::Mongoid::Document
  include Mongoid::Tree

  # -- Fields ---------------------------------------------------------------
  field :label,      :type => String
  field :slug,       :type => String
  field :content,    :type => String
  field :css,        :type => String
  field :js,         :type => String
  field :position,   :type => Integer, :default => 0

  # -- Relationships --------------------------------------------------------
  referenced_in :jangle_site,
    :class_name => 'Jangle::Site',
    :inverse_of => :jangle_templates
  references_many :jangle_widgets,
    :class_name => 'Jangle::Widget',
    :inverse_of => :jangle_template,
    :dependent => :nullify

  # -- Validations ----------------------------------------------------------
  validates :jangle_site_id,
    :presence   => true
  validates :label,
    :presence   => true
  validates :slug,
    :presence   => true,
    :uniqueness => { :scope => :jangle_site_id },
    :format     => { :with => /^\w[a-z0-9_-]*$/i }
  validates :content,
    :presence   => true
  validate :check_content_tag_presence

  # -- Class Methods --------------------------------------------------------
  # Tree-like structure for templates
  def self.options_for_select(jangle_site, jangle_template = nil, current_template = nil, depth = 0, spacer = '. . ')
    out = []
    [current_template || jangle_site.jangle_templates.roots].flatten.each do |template|
      next if jangle_template == template
      out << [ "#{spacer*depth}#{template.label}", template.id ]
      template.children.each do |child|
        out += options_for_select(jangle_site, jangle_template, child, depth + 1, spacer)
      end
    end
    return out.compact
  end

  # -- Instance Methods -----------------------------------------------------
  # magical merging tag is {cms:template:content} If parent layout has this tag
  # defined its content will be merged. If no such tag found, parent content
  # is ignored.
  def merged_content
    if parent
      regex = /\{\{\s*cms:template:content:?(?:(?::text)|(?::rich_text))?\s*\}\}/
      if parent.merged_content.match(regex)
        parent.merged_content.gsub(regex, content)
      else
        content
      end
    else
      content
    end
  end

protected
  def check_content_tag_presence
    CmsTag.process_content((test_widget = Jangle::Widget.new), content)
    if test_widget.cms_tags.select{ |t| t.class.respond_to?(:cms_tag_class) ? t.class.cms_tag_class == Jangle::WidgetBlock : false }.blank?
      self.errors.add(:content, 'No cms widget tags defined')
    end
  end
end