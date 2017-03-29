require "test_helper"
module Ddt
  module BillTemplate
    module Tag
      class IfTest < TestCase::Base
        def test_render_with_type
          tag = Tag::If.new(body: "<if type='fastfood'>\nfastfood</if>", attrs: { type: 'fastfood' }, content: "\nfastfood")
          order = mock()
          order.stubs(:type_str).returns("fastfood")
          output = tag.render(order)
          assert_equal "\nfastfood", output
        end

        def test_render_with_diff_type
          tag = Tag::If.new(body: "<if type='fastfood'>\nfastfood</if>", attrs: { type: 'fastfood' }, content: "\nfastfood")
          order = mock()
          order.stubs(:type_str).returns("eat_in_hall")
          output = tag.render(order)
          assert_equal "", output
        end

        def test_render_with_present
          tag = Tag::If.new(body: "<if present='note'>note</if>", attrs: { present: 'note' }, content: "note")
          order = mock()
          order.stubs(:note).returns("note")
          output = tag.render(order)
          assert_equal "note", output
        end

        def test_render_with_blank_present
          tag = Tag::If.new(body: "<if present='note'>note</if>", attrs: { present: 'note' }, content: "note")
          order = mock()
          order.stubs(:note).returns("")
          output = tag.render(order)
          assert_equal "", output
        end

        def test_render_with_item_present
          tag = Tag::If.new(body: "<if item_present='item_note'>note</if>", attrs: { item_present: 'item_note' }, content: "note")
          item = mock()
          item.stubs(:item_note).returns("note")
          output = tag.render(nil, item)
          assert_equal "note", output
        end
      end
    end
  end
end