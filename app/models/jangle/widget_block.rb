class Jangle::WidgetBlock < Jangle::Block
  referenced_in :jangle_widget,
    :class_name => 'Jangle::Widget',
    :inverse_of => :jangle_blocks

  # -- Class Methods --------------------------------------------------------
  def self.initialize_or_find(jangle_widget, label)
    if block = jangle_widget.jangle_blocks.where(label: label.to_s).first
      self.new(
        :record_id     => block.id,
        :jangle_widget => jangle_widget,
        :label         => block.label,
        :content       => block.content
      )
    else
      self.new(
        :label         => label.to_s,
        :jangle_widget => jangle_widget
      )
    end
  end
end