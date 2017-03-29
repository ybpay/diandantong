# encoding:utf-8
module Ddt
  module Backend
    module ServiceProductsHelper

      def service_product_form_url(service_product)
        if service_product.new_record?
          backend_service_products_path
        else
          backend_service_product_path(service_product)
        end
      end

      def preference_id(key)
        "preference_#{key}"
      end

      def preference_input(key, value)
        name = "preferences[#{key}]"
        klass = "form-control"
        tag(:input, id: preference_id(key), type: "text", class: klass, name: name, value: value)
      end

    end
  end
end
