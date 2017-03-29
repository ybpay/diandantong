module Ddt
  module BillTemplate
    module Tag
      class ItemQuantity < Tag::Base
        tag_attr :width, :int, default: 3
        tag_attr :align, :string, default: "right"

        def render(quantity)
          "%#{'-' if align.to_s == 'left'}#{width}d" % quantity
        end
      end
    end
  end
end