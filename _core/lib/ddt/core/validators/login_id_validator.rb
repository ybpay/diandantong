# encoding : utf-8
class LoginIdValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A[a-zA-Z][a-zA-Z0-9_:]{2,}\Z/i
      record.errors[attribute] << (options[:message] || "格式错误，必须以字母开头，长度不得小于3个字符")
    end

    # login_id 和 slug 不能以 `gh_` 开头
    if value =~ /\Agh_.*/i
      record.errors[attribute] << (options[:message] || "不能以gh_开头")
    end
  end
end
