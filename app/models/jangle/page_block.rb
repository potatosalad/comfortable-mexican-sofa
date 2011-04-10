class Jangle::PageBlock < Jangle::Block
  referenced_in :jangle_page,
    :class_name => 'Jangle::Page',
    :inverse_of => :jangle_blocks

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