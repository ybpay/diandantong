# encoding: utf-8
module Ddt
  class FormElementOption < FormElement
    ### relationships
    belongs_to :select, class_name: 'FormElementSelect', foreign_key: :form_element_id
  end
end
