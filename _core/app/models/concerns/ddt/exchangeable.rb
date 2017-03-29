# encoding:utf-8
module Ddt
  module Exchangeable
    extend ActiveSupport::Concern
    included do
      has_one :exchange_code, as: :exchangeable
      delegate :id, :state, :state_name, to: :exchange_code, allow_nil: true, prefix: true
      delegate :exchanged?, :exchange, to: :exchange_code, allow_nil: true
    end

    def exchange_detail
      raise 'exchange_detail'
    end

    def exchange_detail_decode
      ::HTMLEntities.new.decode(ActionView::Base.full_sanitizer.sanitize(self.exchange_detail))
    end

    def after_exchange
    end
  end
end