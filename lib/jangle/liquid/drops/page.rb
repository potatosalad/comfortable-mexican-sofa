module Jangle
  module Liquid
    module Drops
      class Page < Base

        liquid_attributes << :label << :slug << :url

        def children
          @children ||= liquify(*@source.children)
        end

      end
    end
  end
end