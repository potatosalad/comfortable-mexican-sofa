class CmsBlock
  include Mongoid::Document
  include Mongoid::Timestamps

  # -- Fields ---------------------------------------------------------------
  field :label,   :type => String
  field :content, :type => String

  # -- Relationships --------------------------------------------------------
  referenced_in :cms_page

  # -- Validations ----------------------------------------------------------
  #validates :label,
  #  :presence   => true,
  #  :uniqueness => { :scope => :cms_page_id }

  # -- Class Methods --------------------------------------------------------
  def self.initialize_or_find(cms_page, label)
    if block = cms_page.cms_blocks.where(:label => label.to_s).first
      self.new(
        :record_id  => block.id,
        :cms_page   => cms_page,
        :label      => block.label,
        :content    => block.content
      )
    else
      self.new(
        :label    => label.to_s,
        :cms_page => cms_page
      )
    end
  end
end