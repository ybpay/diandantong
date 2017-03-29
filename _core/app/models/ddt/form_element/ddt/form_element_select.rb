# encoding: utf-8
module Ddt
  class FormElementSelect < FormElement
    ### relationships
    has_many :options, class_name: 'FormElementOption', foreign_key: :form_element_id
  end
end
