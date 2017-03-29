# encoding : utf-8
class CnameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    source = options[:source]
    if source.present? and source.is_a? Proc
      source = source.call(value, record)
    else
      source = value
    end

    target = options[:target]
    if target.present? and target.is_a? Proc
      target = target.call(value, record)
    else
      target = Ddt::Host::DEPLOY
    end

    unless validate_cname(source, target)
      record.errors[attribute] << (options[:message] || " #{source} 的 cname 记录未指向 #{target}")
    end
  end
  private
  def validate_cname(source, target)
    success = false
    Resolv::DNS.new.getresources(source, Resolv::DNS::Resource::IN::CNAME).find { |it|
      success = true if it.name.to_s == target
    }
    success
  end
end
