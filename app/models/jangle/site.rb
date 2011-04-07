class Jangle::Site
  include Mongoid::Document

  # -- Fields ---------------------------------------------------------------
  field :label,    :type => String
  field :hostname, :type => String

  # -- Relationships --------------------------------------------------------
  references_many :cms_layouts, :dependent => :destroy, :class_name => 'Jangle::Layout' do
    def find_by_slug(slug)
      @target.where(:slug => slug).first
    end
  end
  references_many :cms_pages, :dependent => :destroy, :class_name => 'Jangle::Page' do
    def find_by_full_path(full_path)
      @target.where(:full_path => full_path).first
    end
  end
  references_many :cms_snippets, :dependent => :destroy, :class_name => 'Jangle::Snippet'
  references_many :cms_uploads,  :dependent => :destroy, :class_name => 'Jangle::Upload'

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
end