class Jangle::Widget
  include Jangle::Mongoid::Document
  include Mongoid::Tree

  include Models::Jangle::Extensions::Parse
  include Models::Jangle::Extensions::Render

  attr_accessor :cms_tags

  # -- Fields ---------------------------------------------------------------
  field :label,     :type => String
  field :slug,      :type => String
  field :content,   :type => String
  field :position,  :type => Integer, :default => 0

  # -- Relationships --------------------------------------------------------
  referenced_in :jangle_site,
    :class_name => 'Jangle::Site',
    :inverse_of => :jangle_widgets
  referenced_in :jangle_template,
    :class_name => 'Jangle::Template',
    :inverse_of => :jangle_widgets
  #references_many :jangle_blocks,
  embeds_many :jangle_blocks,
    :class_name => 'Jangle::WidgetBlock',
    :inverse_of => :jangle_widget,
    :dependent  => :destroy
  accepts_nested_attributes_for :jangle_blocks

  # -- Callbacks ------------------------------------------------------------
  before_validation :assign_position,
                    :on => :create
  before_save :set_cached_content

  # -- Scopes ---------------------------------------------------------------
  default_scope :order => :position

  # -- Class Methods --------------------------------------------------------
  # Tree-like structure for pages
  def self.options_for_select(jangle_site, jangle_widget = nil, current_widget = nil, depth = 0, exclude_self = true, spacer = '. . ')
    out = []
    [current_widget || jangle_site.jangle_widgets.roots].flatten.each do |widget|
      next if jangle_widget == widget
      out << [ "#{spacer*depth}#{widget.label}", widget.id ]
      widget.children.each do |child|
        out += options_for_select(jangle_site, jangle_widget, child, depth + 1, spacer)
      end
    end
    return out.compact
  end

  def self.initialize_or_find(jangle_widget, slug)
    load_for_slug(jangle_widget.jangle_site, slug) || new(:slug => slug)
  end

  # Wrapper around load_from_file and find_by_slug
  # returns layout object if loaded / found
  def self.load_for_slug!(site, slug)
    if Jangle.configuration.seed_data_path
      load_from_file(site, slug)
    else
      # FIX: This a bit odd... Snippet is used as a tag, so sometimes there's no site scope
      # being passed. So we're enforcing this only if it's found. Need to review.
      conditions = site ? {:conditions => {:jangle_site_id => site.id}} : {}
      where(:slug => slug).find(:first, conditions)
    end || raise(Mongoid::Errors::DocumentNotFound.new(self, slug), "Jangle::Widget with slug: #{slug} cannot be found")
  end

  # Non-blowing-up version of the method above
  def self.load_for_slug(site, slug)
    load_for_slug!(site, slug) 
  rescue Mongoid::Errors::DocumentNotFound
    nil
  end

  # -- Instance Methods -----------------------------------------------------
  # Transforms existing jangle_block information into a hash that can be used
  # during form processing. That's the only way to modify jangle_blocks.
  def jangle_blocks_attributes
    self.jangle_blocks.inject([]) do |arr, block|
      block_attr = {}
      block_attr[:label]    = block.label
      block_attr[:content]  = block.content
      block_attr[:id]       = block.id
      arr << block_attr
    end
  end

  # Processing content will return rendered content and will populate 
  # self.cms_tags with instances of CmsTag
  def content(force_reload = false)
    @content = read_attribute(:content)
    @content = nil if force_reload
    @content ||= begin
      self.cms_tags = [] # resetting
      jangle_template ? CmsTag.process_content(self, jangle_template.merged_content) : ''
    end
  end

  # Array of cms_tags for a page. Content generation is called if forced.
  # These also include initialized jangle_blocks if present
  def cms_tags(force_reload = false)
    self.content(true) if force_reload
    @cms_tags ||= []
  end

protected

  def assign_position
    return unless self.parent
    high = self.parent.children.order_by([ :position, :desc ]).first
    max = high ? high.position : 0
    self.position = max ? max + 1 : 0
  end

  def set_cached_content
    write_attribute(:content, self.content(true))
  end
end