module Ddt
  module OrderService
    module Collection
      class LineItemTracePoints < Collection::Base
        [:pending, :confirmed, :completed, :canceled].each do |state|
          scope state, ->{ select{|item| item.send("is_#{state}?")}}
        end

        scope :by_itemable, ->(itemable){ select{|item| item.itemable_type == itemable.itemable_type && item.itemable_id == itemable.itemable_id}}
        scope :by_line_item, ->(line_item){ select{|item| item.line_item_id == line_item.id}}
      end
    end
  end
end