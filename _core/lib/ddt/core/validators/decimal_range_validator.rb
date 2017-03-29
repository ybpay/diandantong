# encoding: utf-8
# Range restrict for decimal column
class DecimalRangeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    column_msg = record.class.columns.detect{|column| column.name == attribute.to_s}
    max_value = 10**(column_msg.precision - column_msg.scale)
    min_value = -max_value
    unless ((min_value+1)...max_value).include? value
      record.errors[attribute] << (options[:message] || "数值超过许可范围")
    end
  end
end
