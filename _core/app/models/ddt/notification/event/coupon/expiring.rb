module Ddt
  class Notification
    module Event
      module Coupon
        class Expiring < Ddt::Notification::Event::Coupon::Base
          # 券即将过期
        end
      end
    end
  end
end
