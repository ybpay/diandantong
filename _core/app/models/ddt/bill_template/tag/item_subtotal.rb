module Ddt
  module BillTemplate
    module Tag
      class ItemSubtotal < Tag::Base
        tag_attr :width, :int, default: 7
        tag_attr :align, :string, default: "right"
        tag_attr :scale, :int, default: 2

        def render(subtotal)
          "%#{'-' if align.to_s == 'left'}#{width}.#{scale}f" % subtotal
        end
      end
    end
  end
end