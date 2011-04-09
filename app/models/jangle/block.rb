class Jangle::Block
  include Jangle::Mongoid::Document

  # -- Fields ---------------------------------------------------------------
  field :label,   :type => String
  field :content, :type => String

  # -- Relationships --------------------------------------------------------
  referenced_in :jangle_page,
    :class_name => 'Jangle::Page',
    :inverse_of => :jangle_blocks
  referenced_in :jangle_widget,
    :class_name => 'Jangle::Widget',
    :inverse_of => :jangle_blocks

  # -- Validations ----------------------------------------------------------
  #validates :label,
  #  :presence   => true,
  #  :uniqueness => { :scope => :jangle_page_id }

  # -- Class Methods --------------------------------------------------------
  def self.initialize_or_find(jangle_page, label)
    if block = jangle_page.jangle_blocks.where(label: label.to_s).first
      self.new(
        :record_id  => block.id,
        :jangle_page   => jangle_page,
        :label      => block.label,
        :content    => block.content
      )
    else
      self.new(
        :label    => label.to_s,
        :jangle_page => jangle_page
      )
    end
  end
end