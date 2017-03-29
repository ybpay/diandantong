# encoding : utf-8
class UnchangableAfterSaveValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if (record.send "#{attribute}_changed?".to_sym) && !record.changes["#{attribute}".to_sym][0].blank?
      record.errors[attribute] << (options[:message] || "一旦设置，不允许更改")
    end
  end
end