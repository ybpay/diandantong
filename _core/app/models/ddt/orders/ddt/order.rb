module Ddt
  class Order < ActiveRecord::Base
    CANCEL_REASONS = %w[货物售罄 地址无效 超出范围 无法配送 定单无效 其他原因]
  end
end