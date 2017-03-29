require "test_helper"
module Ddt
  module BillTemplate
    module Tag
      class ItemPriceTest < TestCase::Base
        let(:price){ 1.11 }
        def test_render_with_width
          tag = Tag::ItemPrice.new(body: "<item-price width=5/>", attrs: { width: 5 }, content: "")
          output = tag.render(price)
          assert_equal " 1.11", output
        end

        def test_render_with_scale
          tag = Tag::ItemPrice.new(body: "<item-price width=5 scale=1/>", attrs: { width: 5, scale: 1 }, content: "")
          output = tag.render(price)
          assert_equal "  1.1", output
        end

        def test_render_with_align
          tag = Tag::ItemPrice.new(body: "<item-price width=5 align='left'/>", attrs: { width: 5, align: :left }, content: "")
          output = tag.render(price)
          assert_equal "1.11 ", output
        end
      end
    end
  end
end