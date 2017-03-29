require "test_helper"
module Ddt
  module BillTemplate
    module Tag
      class ItemNameTest < TestCase::Base
        def test_render_width
          tag = Tag::ItemName.new(body: "<item-name width=5/>", attrs: { width: 5 }, content: "")
          output = tag.render("name")
          assert_equal "name ", output
        end

        def test_render_with_align
          tag = Tag::ItemName.new(body: "<item-name width=5 align='right'/>", attrs: { width: 5, align: 'right'}, content: "")
          output = tag.render("name")
          assert_equal " name", output
        end

        def test_render_overflow
          tag = Tag::ItemName.new(body: "<item-name width=5/>", attrs: { width: 5 }, content: "")
          name = "111112222233333"
          output = tag.render(name)
          overflow = tag.render_overflow(name)
          assert_equal "11111", output
          assert_equal " 22222", overflow[0]
          assert_equal " 33333", overflow[1]
        end
      end
    end
  end
end