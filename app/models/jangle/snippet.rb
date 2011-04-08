class Jangle::Snippet
  include Mongoid::Document
  include Mongoid::Timestamps

  # -- Fields ---------------------------------------------------------------
  field :label,   :type => String
  field :slug,    :type => String
  field :content, :type => String

  # -- Relationships --------------------------------------------------------
  referenced_in :jangle_site,
    :class_name => 'Jangle::Site',
    :inverse_of => :jangle_snippets

  # -- Callbacks ------------------------------------------------------------
  after_save    :clear_cached_page_content
  after_destroy :clear_cached_page_content

  # -- Validations ----------------------------------------------------------
  validates :jangle_site_id,
    :presence   => true
  validates :label,
    :presence   => true
  validates :slug,
    :presence   => true,
    :uniqueness => { :scope => :jangle_site_id },
    :format     => { :with => /^\w[a-z0-9_-]*$/i }

  # -- Class Methods --------------------------------------------------------
  def self.content_for(slug)
    (s = find_by_slug(slug)) ? s.content : ''
  end

  def self.initialize_or_find(jangle_page, slug)
    load_for_slug(jangle_page.jangle_site, slug) || new(:slug => slug)
  end

  # Attempting to initialize snippet object from yaml file that is found in config.seed_data_path
  def self.load_from_file(site, name)
    return nil if Jangle.config.seed_data_path.blank?
    file_path = "#{Jangle.config.seed_data_path}/#{site.hostname}/snippets/#{name}.yml"
    return nil unless File.exists?(file_path)
    attributes = YAML.load_file(file_path).symbolize_keys!
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
      # FIX: This a bit odd... Snippet is used as a tag, so sometimes there's no site scope
      # being passed. So we're enforcing this only if it's found. Need to review.
      conditions = site ? {:conditions => {:jangle_site_id => site.id}} : {}
      where(:slug => slug).find(:first, conditions)
    end || raise(Mongoid::Errors::DocumentNotFound.new(self, slug), "Jangle::Snippet with slug: #{slug} cannot be found")
  end

  # Non-blowing-up version of the method above
  def self.load_for_slug(site, slug)
    load_for_slug!(site, slug) 
  rescue Mongoid::Errors::DocumentNotFound
    nil
  end

protected

  # Note: This might be slow. We have no idea where the snippet is used, so
  # gotta reload every single page. Kinda sucks, but might be ok unless there
  # are hundreds of pages.
  def clear_cached_page_content
    Jangle::Page.all.each{ |page| page.save! }
  end
end