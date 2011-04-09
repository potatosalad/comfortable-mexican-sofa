module Models
  module Jangle
    module Extensions
      module Render
        def render(context)
          self.template.render(context)
        end
      end
    end
  end
end