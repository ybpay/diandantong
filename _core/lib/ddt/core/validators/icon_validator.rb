# encoding : utf-8
class IconValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\Afa-[a-zA-Z0-9\-]{2,}\Z/i
      record.errors[attribute] << (options[:message] || "格式错误")
    end
  end
end