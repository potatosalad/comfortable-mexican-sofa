class Jangle::Site
  include Jangle::Mongoid::Document

  # -- Fields ---------------------------------------------------------------
  field :label,    :type => String
  field :hostname, :type => String

  # -- Relationships --------------------------------------------------------
  references_many :jangle_layouts,
    :class_name => 'Jangle::Layout',
    :inverse_of => :jangle_site,
    :dependent => :destroy do
    def find_by_slug(slug)
      @target.where(:slug => slug).first
    end
  end
  references_many :jangle_pages,
    :class_name => 'Jangle::Page',
    :inverse_of => :jangle_site,
    :dependent => :destroy do
    def find_by_full_path(full_path)
      @target.where(:full_path => full_path).first
    end
  end
  references_many :jangle_templates,
    :class_name => 'Jangle::Template',
    :inverse_of => :jangle_site,
    :dependent => :destroy do
    def find_by_slug(slug)
      @target.where(:slug => slug).first
    end
  end
  references_many :jangle_widgets,
    :class_name => 'Jangle::Widget',
    :inverse_of => :jangle_site,
    :dependent => :destroy do
    def find_by_slug(slug)
      @target.where(:slug => slug).first
    end
  end
  references_many :jangle_snippets,
    :class_name => 'Jangle::Snippet',
    :inverse_of => :jangle_site,
    :dependent => :destroy
  references_many :jangle_uploads,
    :class_name => 'Jangle::Upload',
    :inverse_of => :jangle_site,
    :dependent => :destroy

  # -- Validations ----------------------------------------------------------
  validates :label,
    :presence   => true,
    :uniqueness => true
  validates :hostname,
    :presence   => true,
    :uniqueness => true,
    :format     => { :with => /^[\w\.\-]+$/ }

  # -- Class Methods --------------------------------------------------------
  def self.options_for_select
    Jangle::Site.all.collect{|s| ["#{s.label} (#{s.hostname})", s.id]}
  end

  def self.find_by_hostname!(hostname)
    criteria = where(:hostname => hostname)
    raise Mongoid::Errors::DocumentNotFound.new(self, hostname) unless criteria.exists?
    criteria.first
  end

  def self.find_by_hostname(hostname)
    find_by_hostname!(hostname)
  rescue Mongoid::Errors::DocumentNotFound
    return nil
  end

  # -- Instance Methods -----------------------------------------------------
  def to_liquid
    Jangle::Liquid::Drops::Site.new(self)
  end
end