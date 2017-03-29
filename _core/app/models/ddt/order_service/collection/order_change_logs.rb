module Ddt
  module OrderService
    module Collection
      class OrderChangeLogs < Collection::Base
        [:order_place, :order_confirm, :order_complete, :order_pay, :order_cancel,
          :append_itemable, :delete_itemable, :move_itemable,
          :change_table, :merge_table].each do |name|
          scope name, ->{ select{|item| item.type == "Ddt::OrderChangeLog::#{name.to_s.classify}"} }
        end
        alias_method :subtract_itemable, :delete_itemable


        scope :place_and_append, -> {
          select{|item| ['Ddt::OrderChangeLog::OrderPlace', 'Ddt::OrderChangeLog::AppendItemable'].include?(item.type)}
        }

        def place_log
          order_place.first
        end

        def cancel_log
          order_cancel.first
        end

        def last_log
          sort_by{|item| item.created_at}.last
        end

        def last_delete_log
          delete_itemable.sort_by{|item| item.created_at}.last
        end

        def last_append_log
          append_itemable.sort_by{|item| item.created_at}.last
        end

      end
    end
  end
end
