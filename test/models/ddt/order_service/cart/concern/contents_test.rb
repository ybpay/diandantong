module Ddt
  module OrderService
    module Cart
      module Concern
        module ContentsTest
          extend ActiveSupport::Concern
          concerning :Add do
            def test_add
              cart.add(itemable)
              assert_equal cart.line_items.count, 1
            end

            def test_add_without_merge
              cart.add(itemable, merge: false)
              cart.add(itemable, merge: false)
              assert_equal cart.line_items.count, 2
            end

            def test_add_with_merge
              cart.add(itemable, merge: true)
              cart.add(itemable, merge: true)
              assert_equal cart.line_items.count, 1
            end

            def test_add_with_min_quantity_for_order
              itemable.stubs(:min_quantity_for_order).returns(2)
              cart.add(itemable)
              assert_equal cart.line_items.first.quantity, 2
            end
          end

          concerning :Remove do
            def test_remove
              cart.add(itemable)
              cart.remove(itemable)
              assert_equal cart.line_items.count, 0
            end

            def test_remove_with_min_quantity_for_order
              cart.add(itemable, quantity: 2)
              itemable.stubs(:min_quantity_for_order).returns(2)
              cart.remove(itemable)
              assert_equal cart.line_items.count, 0
            end
          end

          def test_clear
            cart.add(itemable)
            cart.clear
            assert_equal cart.line_items.count, 0
          end

          concerning :UpdateLineItems do
            def test_update_line_items
              line_itemable = itemable.to_line_itemable
              cart.update_line_items([line_itemable, line_itemable])
              assert_equal cart.line_items.count, 2
            end
          end

          concerning :UpdateFormContents do
            def test_update_form_contents
              form_contentables = OrderService::FormContentable.init_list([
                { form_element_id: form_element_text.id, content: "content"},
                { form_element_id: form_element_select.id, type: :quote, content: form_element_select.form_elements.first.id }
              ])
              cart.update_form_contents(form_contentables)
              assert_equal cart.form_contents.count, 2
            end
          end
        end
      end
    end
  end
end