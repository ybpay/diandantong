module Ddt
  module BillTemplate
    module Tag
      class ItemPrice < Tag::Base
        tag_attr :width, :int, default: 7
        tag_attr :align, :string, default: "right"
        tag_attr :scale, :int, default: 2

        def render(price)
          "%#{'-' if align.to_s == 'left'}#{width}.#{scale}f" % price
        end
      end
    end
  end
end