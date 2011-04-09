module Jangle
  module Liquid
    module Drops
      class Site < Base

        liquid_attributes << :label << :hostname

        def index
          @index ||= @source.jangle_pages.root.first
        end

        def pages
          @pages ||= @source.jangle_pages.to_a.collect(&:to_liquid)
        end

      end
    end
  end
end