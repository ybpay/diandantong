#encoding: utf-8
module Ddt
  module ShakeAround
    class BeaconInfo < Ddt::Base
      # device_id #   对于微信的deviceid
      # comment       设备备注
      # major
      # minor
      # uuid
      # distance
      # is_chosen true 表示是选择的， false表示是周边的
      # shake_info_id
      # wechat_account_id
      # shop_id

      belongs_to :shake_info, class_name: 'Ddt::ShakeAround::ShakeInfo'

      before_validation :set_device_info

      private

        def set_device_info
          if self.device_id.blank?
            device = Ddt::ShakeAround::Device.find_by(uuid: self.uuid, major: self.major, minor: self.minor)
            self.comment = device.comment
            self.device_id = device.device_id
            self.shop_id = device.shop_id
            self.wechat_account_id = device.wechat_account_id
          end
        end
    end
  end
end
