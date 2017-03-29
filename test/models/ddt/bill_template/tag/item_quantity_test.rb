require "test_helper"
module Ddt
  module BillTemplate
    module Tag
      class ItemQuantityTest < TestCase::Base
        let(:quantity){ 1 }
        def test_render_with_width
          tag = Tag::ItemQuantity.new(body: "<item-quantity width=3/>", attrs: { width: 3 }, content: "")
          output = tag.render(quantity)
          assert_equal "  1", output
        end

        def test_render_with_align
          tag = Tag::ItemQuantity.new(body: "<item-quantity width=3 align='left'/>", attrs: { width: 3, align: :left }, content: "")
          output = tag.render(quantity)
          assert_equal "1  ", output
        end
      end
    end
  end
end