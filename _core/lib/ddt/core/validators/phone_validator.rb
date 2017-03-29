# encoding : utf-8
class PhoneValidator < ActiveModel::EachValidator
  REGEXP = /\A((0?1\d{10})|((0[1-9]\d{1,2}-)?\d{7,8})|(0\d{9}))|([1-9]\d{4,5})\Z/i
  def validate_each(record, attribute, value)
    unless value =~ REGEXP
      record.errors[attribute] << (options[:message] || "格式错误")
    end
  end
end