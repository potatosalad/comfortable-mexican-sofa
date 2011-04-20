class Jangle::Page
  include Jangle::Mongoid::Document
  include Mongoid::Tree

  include Models::Jangle::Extensions::Parse
  include Models::Jangle::Extensions::Render

  attr_accessor :cms_tags

  # -- Fields ---------------------------------------------------------------
  field :label,        :type => String
  field :slug,         :type => String
  field :full_path,    :type => String
  field :content,      :type => String
  field :position,     :type => Integer, :default => 0
  field :is_published, :type => Boolean, :default => false

  # -- Relationships --------------------------------------------------------
  referenced_in :jangle_site,
    :class_name => 'Jangle::Site',
    :inverse_of => :jangle_pages
  referenced_in :jangle_layout,
    :class_name => 'Jangle::Layout',
    :inverse_of => :jangle_pages
  referenced_in :target_page,
    :class_name => 'Jangle::Page'
  #references_many :jangle_blocks,
  embeds_many :jangle_blocks,
    :class_name => 'Jangle::PageBlock',
    :inverse_of => :jangle_page,
    :dependent  => :destroy
  accepts_nested_attributes_for :jangle_blocks

  # -- Callbacks ------------------------------------------------------------
  before_validation :assign_parent,
                    :assign_full_path
  before_validation :assign_position,
                    :on => :create
  before_save :set_cached_content
  after_save  :sync_child_pages

  # -- Validations ----------------------------------------------------------
  validates :jangle_site_id, 
    :presence   => true
  validates :label,
    :presence   => true
  validates :slug,
    :presence   => true,
    :format     => /^\w[a-z0-9_-]*$/i,
    :unless     => lambda{ |p| p == Jangle::Page.root || Jangle::Page.count == 0 }
  validates :jangle_layout,
    :presence   => true
  validates :full_path,
    :presence   => true,
    :uniqueness => { :scope => :jangle_site_id }
  validate :validate_target_page

  # -- Scopes ---------------------------------------------------------------
  default_scope :order => :position
  scope :published, :where => { :is_published => true }

  # -- Class Methods --------------------------------------------------------
  # Tree-like structure for pages
  def self.options_for_select(jangle_site, jangle_page = nil, current_page = nil, depth = 0, exclude_self = true, spacer = '. . ')
    return [] if (current_page ||= jangle_site.jangle_pages.root) == jangle_page && exclude_self || !current_page
    out = []
    out << [ "#{spacer*depth}#{current_page.label}", current_page.id ] unless current_page == jangle_page
    current_page.children.each do |child|
      out += options_for_select(jangle_site, jangle_page, child, depth + 1, exclude_self, spacer)
    end
    return out.compact
  end

  # Attempting to initialize page object from yaml file that is found in config.seed_data_path
  # This file defines all attributes of the page plus all the block information
  def self.load_from_file(site, path)
    return nil if Jangle.config.seed_data_path.blank?
    path = (path == '/')? '/index' : path.to_s.chomp('/')
    file_path = "#{Jangle.config.seed_data_path}/#{site.hostname}/pages#{path}.yml"
    return nil unless File.exists?(file_path)
    attributes              = YAML.load_file(file_path).symbolize_keys!
    attributes[:jangle_layout] = Jangle::Layout.load_from_file(site, attributes[:jangle_layout])
    attributes[:parent]     = Jangle::Page.load_from_file(site, attributes[:parent])
    attributes[:jangle_site]   = site
    attributes[:target_page]= Jangle::Page.load_from_file(site, attributes[:target_page])
    new(attributes)
  rescue
    raise "Failed to load from #{file_path}"
  end

  # Wrapper around load_from_file and find_by_full_path
  # returns page object if loaded / found
  def self.load_for_full_path!(site, path)
    if Jangle.configuration.seed_data_path
      load_from_file(site, path)
    else
      site.jangle_pages.find_by_full_path(path)
    end || raise(Mongoid::Errors::DocumentNotFound.new(self, path), "Jangle::Page with path: #{path} cannot be found")
  end

  # Non-blowing-up version of the method above
  def self.load_for_full_path(site, path)
    load_for_full_path!(site, path) 
  rescue Mongoid::Errors::DocumentNotFound
    nil
  end

  # -- Instance Methods -----------------------------------------------------
  # For previewing purposes sometimes we need to have full_path set
  def full_path
    self.read_attribute(:full_path) || self.assign_full_path
  end

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
      jangle_layout ? CmsTag.process_content(self, jangle_layout.merged_content) : ''
    end
  end

  # Array of cms_tags for a page. Content generation is called if forced.
  # These also include initialized jangle_blocks if present
  def cms_tags(force_reload = false)
    self.content(true) if force_reload
    @cms_tags ||= []
  end

  # Full url for a page
  def url
    "http://#{self.jangle_site.hostname}#{self.full_path}"
  end

  def to_liquid
    Jangle::Liquid::Drops::Page.new(self)
  end

protected

  def assign_parent
    self.parent ||= Jangle::Page.root unless self == Jangle::Page.root || Jangle::Page.count == 0
  end

  def assign_full_path
    self.full_path = self.parent ? "#{self.parent.full_path}/#{self.slug}".squeeze('/') : '/'
  end

  def assign_position
    return unless self.parent
    high = self.parent.children.order_by([ :position, :desc ]).first
    max = high ? high.position : 0
    self.position = max ? max + 1 : 0
  end

  def validate_target_page
    return unless self.target_page
    p = self
    while p.target_page do
      return self.errors.add(:target_page_id, 'Invalid Redirect') if (p = p.target_page) == self
    end
  end

  def set_cached_content
    write_attribute(:content, self.content(true))
  end

  # Forcing re-saves for child pages so they can update full_paths
  def sync_child_pages
    children.each{ |p| p.save! } if full_path_changed?
  end
end