class Jangle::Upload
  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Timestamps

  # -- AR Extensions --------------------------------------------------------
  has_mongoid_attached_file :file, Jangle.config.upload_file_options

  # -- Relationships --------------------------------------------------------
  referenced_in :cms_site, :class_name => 'Jangle::Site'

  # -- Validations ----------------------------------------------------------
  validates :cms_site_id, :presence => true
  validates_attachment_presence :file
end