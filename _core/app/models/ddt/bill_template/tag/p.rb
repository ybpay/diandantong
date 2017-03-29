module Ddt
  module BillTemplate
    module Tag
      class P < Tag::Base
        tag_attr :width, :int, default: 20
        tag_attr :align, :string, default: "left"

        def render
          content.fixed_width(width, float: align).gsub('%', '%%')
        end
      end
    end
  end
end