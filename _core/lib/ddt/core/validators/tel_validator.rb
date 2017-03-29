# encoding : utf-8
class TelValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /((0?\d{11})|^((\d{7,8})|(\d{4}|\d{3})-(\d{7,8})|(\d{4}|\d{3})-(\d{7,8})-(\d{4}|\d{3}|\d{2}|\d{1})|(\d{7,8})-(\d{4}|\d{3}|\d{2}|\d{1}))$)/i
      record.errors[attribute] << (options[:message] || "格式错误")
    end
  end
end