module Ddt
  class Notification
    module Event
      module Coupon
        class Expired < Ddt::Notification::Event::Coupon::Base
          # 券过期
        end
      end
    end
  end
end
