require "test_helper"
module Ddt
  module BillTemplate
    module Tag
      class ItemRepeatTest < TestCase::Base
        let(:item){
          item = mock()
          item.stubs(:is_combo_package?).returns(false)
          item.stubs(:item_name).returns("name")
          item.stubs(:item_quantity).returns(2)
          item.stubs(:item_price).returns(1.11)
          item.stubs(:item_subtotal).returns(2.22)
          item.stubs(:item_note).returns("note")
          item
        }

        def test_strip_content
          tag = Tag::ItemRepeat.new(body: "", attrs: {},
            content: "\r\n <item-name width=5/> \r\n")
          assert_equal "<item-name width=5/>", tag.content
        end

        def test_render_items
          tag = Tag::ItemRepeat.new(body: "", attrs: {},
            content: "<item-name width=11/><item-quantity width=2/><item-price width=5/><item-subtotal width=5/>")
          output = tag.render_items([item])
          assert_equal "name[note]  2 1.11 2.22", output
        end

        def test_render_items_with_overflow
          item.stubs(:item_name).returns("aaaaabbbbbccccc")
          tag = Tag::ItemRepeat.new(body: "", attrs: {},
            content: "<item-name width=5/><item-quantity width=2/><item-price width=5/><item-subtotal width=5/>")
          output = tag.render_items([item])
          assert_equal "aaaaa 2 1.11 2.22\n bbbbb\n ccccc\n [note\n ]   ", output
        end

        def test_renser_items_with_combo
          cart = OrderService::Cart::EatInHall.new(table: table, branch: branch, track_from: :FromWebpos)
          combo_package = create(:combo_with_package, branch: branch).combo_packages.first
          cart.add(combo_package)
          order = cart.place
          tag = Tag::ItemRepeat.new(body: "", attrs: {},
            content: "<item-name width=20/><item-quantity width=2/><item-price width=5/><item-subtotal width=5/>")
          output = tag.render_items(order.line_items.map{|item| TagItem.new(item)}, combo_expand: true)
          assert output.include?(combo_package.product_name)
          assert output.include?(combo_package.combo_package_items.first.variant.name)
        end
      end
    end
  end
end