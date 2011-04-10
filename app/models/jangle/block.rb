class Jangle::Block
  include Jangle::Mongoid::Document

  # -- Fields ---------------------------------------------------------------
  field :label,   :type => String
  field :content, :type => String

  # -- Validations ----------------------------------------------------------
  #validates :label,
  #  :presence   => true,
  #  :uniqueness => { :scope => :jangle_page_id }
end