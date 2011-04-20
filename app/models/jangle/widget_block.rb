class Jangle::WidgetBlock < Jangle::Block
  #referenced_in :jangle_widget,
  #  :class_name => 'Jangle::Widget',
  #  :inverse_of => :jangle_blocks
  embedded_in :jangle_widget,
    :class_name => 'Jangle::Widget',
    :inverse_of => :jangle_blocks

  # -- Class Methods --------------------------------------------------------
  def self.initialize_or_find(jangle_widget, label)
    jangle_widget.jangle_blocks.find_or_initialize_by(label: label.to_s)
  end
end