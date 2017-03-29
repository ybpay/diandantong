#encoding: utf-8
module Ddt
  module OrderFormat
    class Sms < Ddt::OrderFormat::Base
      def content
        detail_array = []
        detail_array << order.branch.name
        detail_array << order.line_items.active.map{|line_item| "#{line_item.name}x#{line_item.active_quantity}"}.join("\n")
        detail_array << order.info_items.map{|item| "[#{item[:name]}#{item[:value]}"}.join("\n")
        detail_array.join("\n")
      end
    end
  end
end
