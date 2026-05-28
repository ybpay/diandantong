# encoding:utf-8
module Ddt
  class MessageHandler
    attr_reader :message
    delegate :shop, :wechat_account, :wechat_user, to: :message
    def initialize(message)
      @message = message
    end

    def build_message
      #特殊对待是因为要处理一些是否关注的关系
      if message.msg_type == 'event' && message.event == 'unsubscribe'
          # 取消关注
          handle_unsubscribe
          return
      end

      wechat_user.update_attribute(:unsubscribed_at, nil)  if wechat_user && wechat_user.unsubscribed_at
      return message.response("对不起，该平台因合约到期已暂停服务") if shop.expired?
      case message.msg_type
      when 'text'
        # 文本信息
        # message.content 文本消息内容
        handle_text
      when 'image'
        # 图片
        # message.pic_url  图片链接
        # message.media_id 图片消息媒体id，可以调用多媒体文件下载接口拉取数据。
        handle_image
      when 'link'
        # 链接
        # message.title        消息标题
        # message.description  消息描述
        # message.url          消息链接
        handle_link
      when 'location'
        # 地理位置消息
        # message.location_x 地理位置纬度
        # message.location_y 地理位置经度
        # message.scale      地图缩放大小
        # message.label      地理位置信息
        handle_location
      when 'event'
        # 事件
        case message.event
        when 'subscribe'
          if message.event_key.present?
            # 二维码扫描关注
            # message.event_key  事件KEY值，qrscene_为前缀，后面为二维码的参数值
            handle_subscribe_with_key
          else
            # 普通关注
            handle_subscribe
          end
        when 'unsubscribe'
          # 取消关注
          #该分支不会被执行，因为已做特殊处理
          #handle_unsubscribe
          raise 'unsubscribe is not supported here'

        when 'SCAN'
          # 已经关注时 扫描二维码
          # message.event_key  事件KEY值，是一个32位无符号整数，即创建二维码时的二维码scene_id
          handle_scan
        when 'LOCATION'
          # 上报地址位置
          # latitude : message.latitude  地理位置纬度
          # longitude : message.longitude 地理位置经度
          # longitude : message.precision  地理位置精度
          handle_report_location
        when 'CLICK'
          # 自定义菜单事件
          # message.event_key 事件KEY值
          # message_response = message.response("自定义菜单事件: #{message.event_key}")
          handle_click
        when 'VIEW'
          # 点击菜单跳转链接
          # message.event_key 跳转URL
          # message_response = message.response("点击菜单跳转链接: #{message.event_key}")
          handle_view
        when 'TEMPLATESENDJOBFINISH'
          # 模版消息发送任务完成
          # message.status ['success', 'failed:user block', 'failed: system failed']
        when 'ShakearoundUserShake'
          # 摇一摇周边
          # mika
        end
      end
    end

    def handle_text
      handle_with_methods(:text)
    end

    def handle_image
      handle_with_methods(:image)
    end

    def handle_link
      handle_with_methods(:link)
    end

    def handle_location
      if wechat_user.user.present?
        wechat_user.user.update(
          last_latitude:        message.location_x,
          last_longitude:       message.location_y,
          last_location_label:  message.label
        )
      end
      handle_with_methods(:location)
    end

    def handle_subscribe_with_key
      scene_id = message.event_key.split("_")[1]
      scan_qr_code(scene_id) if scene_id.present?
      wechat_qr_code_scene = shop.wechat_qr_code_scenes.with_discarded.find_by_scene_id(scene_id)
      if wechat_user.user.present?
        Ddt::Promotion::Events::UserFollow.create!(user: wechat_user.user)
        if wechat_qr_code_scene.present? && wechat_qr_code_scene.is_limit? && wechat_qr_code_scene.is_branch_message? && wechat_user.user.from_branch_id.blank?
          wechat_user.user.update(from_branch_id: wechat_qr_code_scene.branch_id)
        end
      end
      if wechat_qr_code_scene.present?
        handle_with_methods(:subscribe_with_key)
      else
        handle_with_methods(:subscribe)
      end
    end

    def handle_subscribe
      Ddt::Promotion::Events::UserFollow.create!(user: wechat_user.user) if wechat_user.user.present?
      handle_with_methods(:subscribe)
    end

    def handle_unsubscribe
      wechat_user.touch(:unsubscribed_at)
      handle_with_methods(:unsubscribe)
    end

    def handle_scan
      scan_qr_code(message.event_key)
      handle_with_methods(:scan)
    end

    def handle_report_location
      if wechat_user.user.present?
        wechat_user.user.update(
          last_latitude:  message.latitude,
          last_longitude: message.longitude
        )
      end
      handle_with_methods(:report_location)
    end

    def handle_click
      handle_with_methods(:click)
    end

    def handle_view
      handle_with_methods(:view)
    end

    private
    def scan_qr_code(scene_id)
      wechat_qr_code_scene = shop.wechat_qr_code_scenes.find_by_scene_id(scene_id)
      from_user = shop.wechat_users.find_by_user_open_id(message.from_user_name)
      if wechat_qr_code_scene.present? && from_user.present?
        wechat_qr_code_scene.scan_by(from_user)
      end
    end

    def handle_with_methods(type)
      response = Ddt::MessageHandlerMethod::ThirdParty.new(message).send("handle_#{type}")
      response = Ddt::MessageHandlerMethod::Customer.new(message).send("handle_#{type}") if response.blank?
      response = Ddt::MessageHandlerMethod::System.new(message).send("handle_#{type}") if response.blank?
      response
    end
  end
end
