module Models
  module Jangle
    module Extensions
      module Parse
        def template
          @template ||= ::Liquid::Template.parse(self.content)
        end
      end
    end
  end
end