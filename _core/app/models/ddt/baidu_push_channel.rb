# encoding:utf-8
module Ddt
  class BaiduPushChannel < Ddt::Base
    replicated_model

    has_one :account, class_name: 'Ddt::Account'
    default_scope -> {where('expired_at is null or expired_at > NOW()')}
    scope :active, -> {where('updated_at > DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 7 DAY)')}
  end
end


