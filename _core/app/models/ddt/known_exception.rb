#encoding: utf-8
module Ddt
  # 已知异常，不需要发邮件通知开发们处理
  module KnownException
    def self.wrap(e)
      if e.present?
        e.define_singleton_method :send_exception_notification? do false end
      end
      e
    end
  end
end