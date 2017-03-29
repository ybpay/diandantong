# encoding:utf-8
module Ddt
  module Backend
    module CombosHelper
      def combo_shelf_status_label(combo)
        if !combo.on_shelf?
          content_tag(:span, "已下架", class: "label label-default")
        end
      end

    end
  end
end