class CmsSite
  include Mongoid::Document

  # -- Fields ---------------------------------------------------------------
  field :label,    :type => String
  field :hostname, :type => String

  # -- Relationships --------------------------------------------------------
  references_many :cms_layouts,  :dependent => :destroy
  references_many :cms_pages,    :dependent => :destroy
  references_many :cms_snippets, :dependent => :destroy
  references_many :cms_uploads,  :dependent => :destroy

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
    CmsSite.all.collect{|s| ["#{s.label} (#{s.hostname})", s.id]}
  end

  def self.find_by_hostname!(hostname)
    criteria = where(:hostname => hostname)
    raise Mongoid::Errors::DocumentNotFound.new(self, hostname) unless criteria.exists?
    criteria.first
  end

  def self.find_by_id(id)
    return if id.nil?
    find(id)
  end
end