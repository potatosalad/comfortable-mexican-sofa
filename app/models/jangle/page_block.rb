class Jangle::PageBlock < Jangle::Block
  #referenced_in :jangle_page,
  embedded_in :jangle_page,
    :class_name => 'Jangle::Page',
    :inverse_of => :jangle_blocks

  # -- Class Methods --------------------------------------------------------
  def self.initialize_or_find(jangle_page, label)
    jangle_page.jangle_blocks.find_or_initialize_by(label: label.to_s)
  end
end