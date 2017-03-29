# encoding : utf-8
class DomainHostValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A.{2,}\Z/i
      record.errors[attribute] << (options[:message] || "格式错误")
    end
  end
end