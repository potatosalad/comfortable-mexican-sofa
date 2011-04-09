class Jangle::Layout
  include Jangle::Mongoid::Document
  include Mongoid::Tree

  # -- Fields ---------------------------------------------------------------
  field :label,      :type => String
  field :slug,       :type => String
  field :app_layout, :type => String
  field :content,    :type => String
  field :css,        :type => String
  field :js,         :type => String
  field :position,   :type => Integer, :default => 0

  # -- Relationships --------------------------------------------------------
  referenced_in :jangle_site,
    :class_name => 'Jangle::Site',
    :inverse_of => :jangle_layouts
  references_many :jangle_pages,
    :class_name => 'Jangle::Page',
    :inverse_of => :jangle_layout,
    :dependent => :nullify

  # -- Callbacks ------------------------------------------------------------
  after_save    :clear_cache, :clear_cached_page_content
  after_destroy :clear_cache, :clear_cached_page_content

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
  # Tree-like structure for layouts
  def self.options_for_select(jangle_site, jangle_layout = nil, current_layout = nil, depth = 0, spacer = '. . ')
    out = []
    [current_layout || jangle_site.jangle_layouts.roots].flatten.each do |layout|
      next if jangle_layout == layout
      out << [ "#{spacer*depth}#{layout.label}", layout.id ]
      layout.children.each do |child|
        out += options_for_select(jangle_site, jangle_layout, child, depth + 1, spacer)
      end
    end
    return out.compact
  end

  # List of available application layouts
  def self.app_layouts_for_select
    Dir.glob(File.expand_path('app/views/layouts/*.html.*', Rails.root)).collect do |filename|
      match = filename.match(/\w*.html.\w*$/)
      app_layout = match && match[0]
      app_layout.to_s[0...1] == '_' ? nil : app_layout
    end.compact
  end

  # Attempting to initialize layout object from yaml file that is found in config.seed_data_path
  def self.load_from_file(site, slug)
    return nil if Jangle.config.seed_data_path.blank?
    file_path = "#{Jangle.config.seed_data_path}/#{site.hostname}/layouts/#{slug}.yml"
    return nil unless File.exists?(file_path)
    attributes            = YAML.load_file(file_path).symbolize_keys!
    attributes[:parent]   = Jangle::Layout.load_from_file(site, attributes[:parent])
    attributes[:jangle_site] = site
    new(attributes)
  rescue
    raise "Failed to load from #{file_path}"  
  end

  # Wrapper around load_from_file and find_by_slug
  # returns layout object if loaded / found
  def self.load_for_slug!(site, slug)
    if Jangle.configuration.seed_data_path
      load_from_file(site, slug)
    else
      site.jangle_layouts.find_by_slug(slug)
    end || raise(Mongoid::Errors::DocumentNotFound.new(self, slug), "Jangle::Layout with slug: #{slug} cannot be found")
  end

  # Non-blowing-up version of the method above
  def self.load_for_slug(site, slug)
    load_for_slug!(site, slug) 
  rescue Mongoid::Errors::DocumentNotFound
    nil
  end

  # -- Instance Methods -----------------------------------------------------
  # magical merging tag is {cms:page:content} If parent layout has this tag
  # defined its content will be merged. If no such tag found, parent content
  # is ignored.
  def merged_content
    if parent
      regex = /\{\{\s*cms:page:content:?(?:(?::text)|(?::rich_text))?\s*\}\}/
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
    CmsTag.process_content((test_page = Jangle::Page.new), content)
    if test_page.cms_tags.select{ |t| t.class.respond_to?(:cms_tag_class) ? t.class.cms_tag_class == Jangle::Block : false }.blank?
      self.errors.add(:content, 'No cms page tags defined')
    end
  end

  # After saving need to make sure that cached pages for css and js for this
  # layout and its children are gone. Good enough to avoid using cache sweepers.
  def clear_cache
    FileUtils.rm File.expand_path("cms-css/#{self.slug}.css", Rails.public_path), :force => true
    FileUtils.rm File.expand_path("cms-js/#{self.slug}.js",   Rails.public_path), :force => true
  end

  # Forcing page content reload
  def clear_cached_page_content
    self.jangle_pages.each{ |page| page.save! }
    self.children.each{ |child_layout| child_layout.save! }
  end
end