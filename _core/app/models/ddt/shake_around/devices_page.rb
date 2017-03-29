module Ddt
  module ShakeAround
    class DevicesPage < Ddt::Base
      belongs_to :device, class_name: "Ddt::ShakeAround::Device", counter_cache: :count
      belongs_to :bind_page, class_name: "Ddt::ShakeAround::Page", foreign_key: :page_id, counter_cache: :count

      class << self
        def bind_pages(access_token, device, ids, page_ids)
          device_bind_page(access_token, device.device_id, page_ids, 1, 1)
          ids.each do |id|
            create device_id: device.id, page_id: id
          end
        end

        def unbind_pages(access_token, device, ids, page_ids)
          device_bind_page(access_token, device.device_id, page_ids, 0, 0)
          destroy_all(device_id: device.id, page_id: ids)
        end

        def bind_devices(access_token, page, ids, device_ids)
          device_ids.each do |device_id|
            device_bind_page(access_token, device_id, [page.page_id], 1, 1)
          end
          ids.each do |id|
            create device_id: id, page_id: page.id
          end
        end

        def unbind_devices(access_token, page, ids, device_ids)
          device_ids.each do |device_id|
            device_bind_page(access_token, device_id, [page.page_id], 0, 0)
          end
          destroy_all(device_id: ids, page_id: page.id)
        end

        def device_bind_page(access_token, device_id, page_ids, bind, append)
          Ddt::WeixinApi.device_bind_page(access_token, device_id, page_ids, bind, append)
        end
      end
    end
  end
end
