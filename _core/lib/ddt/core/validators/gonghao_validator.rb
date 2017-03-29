# encoding : utf-8
class GonghaoValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\Agh_[a-zA-Z0-9]{12}\Z/i
      record.errors[attribute] << (options[:message] || "格式错误")
    end
  end
end