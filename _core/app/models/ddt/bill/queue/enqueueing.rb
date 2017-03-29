#encoding: utf-8
module Ddt
  module Bill
    module Queue
      class Enqueueing < Ddt::Bill::Queue::Base
        def content(print_qrcode=false)
          view = ""
          view << "\n<C>欢迎光临</C>"
          view << "\n<C>#{branch.name}</C>"
          view << "\n<CB>#{queue_setting.name} #{guest_queue.guest_no}</CB>\n"
          view << "\n<C>人数: #{guest_queue.guest_num}</C>"
          view << "\n<C>还需等待: #{guest_queue.guest_num_at_front}桌</C>"
          view << "\n<C>取号时间: #{guest_queue.created_at.strftime("%Y-%m-%d %H:%M")}</C>"
          view << "\n<C>听到叫号请到迎宾台，过号请重新取号</C>\n"
          if print_qrcode && guest_queue.user.blank?
            if (printer.is_feie? || printer.is_fengchi?) && guest_queue.qr_code_type == :base_qr_code
              view << "\n<C>微信扫描二维码，享受排队实时提醒。在家取号，到号提醒，提前点菜</C>"
              view << "\n<QR>#{guest_queue.weixin_view_url}</QR>"
            else
              qr_code_image_url = guest_queue.qr_code_image
              if qr_code_image_url.present?
                view << "\n<C>微信扫描二维码，享受排队实时提醒。在家取号，到号提醒，提前点菜</C>"
                view << "\n<QRI>#{qr_code_image_url}</QRI>"
                view << "\n<C>2小时内扫描此二维码有效</C>"
              end
            end
          end
          view << "\n"
          if shop.is_oem?
            content_string = "\n<C>#{shop.support_brand_name}提供技术支持，技术支持热线电话#{shop.support_telephone}</C>"
          else
            content_string = "\n<C>点单通提供技术支持，技术支持热线电话40012345678</C>"
          end
          view << content_string
          view << "\n\n\n"
        end
      end
    end
  end
end
