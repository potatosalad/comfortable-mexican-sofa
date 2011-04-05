class CmsUpload
  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Timestamps

  # -- AR Extensions --------------------------------------------------------
  has_mongoid_attached_file :file, ComfortableMexicanSofa.config.upload_file_options

  # -- Relationships --------------------------------------------------------
  referenced_in :cms_site

  # -- Validations ----------------------------------------------------------
  validates :cms_site_id, :presence => true
  validates_attachment_presence :file
end