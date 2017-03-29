# encoding : utf-8
class PasswordValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A[a-zA-Z0-9_]{4,}\Z/i
      record.errors[attribute] << (options[:message] || "格式错误")
    end
  end
end