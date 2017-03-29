# encoding : utf-8
class UriValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    # angular path regexp
    ng_regexp = /^\/|^#\//
    unless (value =~ /\A#{URI::regexp(['http', 'https'])}\z/) || value =~ ng_regexp
      record.errors[attribute] << (options[:message] || "格式错误, 如果您是手动输入的网址，请检查是否缺少前缀: http://")
    end

    # 微信自定义菜单中不允许有\
    invalid_pattern = /\\/
    if value =~ invalid_pattern
      record.errors[attribute] << (options[:message] || "格式错误, 不允许含有\\")
    end
  end
end