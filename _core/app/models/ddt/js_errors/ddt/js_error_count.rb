#encoding: utf-8
module Ddt
  class JsErrorCount < Ddt::DdtEx
    belongs_to :js_error, class_name: 'Ddt::JsError'
    validates :js_error, presence: true
    validates :ip, presence: true
  end
end