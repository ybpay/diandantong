module Ddt
  module Backend
    module FormElementsHelper
      def form_element_regexs
        Ddt::FormElement::Regexs.keys.map{|k| [t("activerecord.attributes.ddt/form_element.regexs.#{k}"), k]}
      end

      def form_element_switch

      end
    end
  end
end

