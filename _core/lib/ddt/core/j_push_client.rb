#encoding:utf-8
module Ddt::JPushClient


  #
  # 推送消息格式
  # {
  #    title: 通知标题
  #    description: 通知内容
  #    custom_content: {
  #       id: 消息 id
  #       shop_id: 门店 id
  #       branch_id: 分店 id
  #       account_id: 当前通知的 account_id
  #       content: 消息内容
  #       event_type: 事件类型
  #       when: 通知时间
  #       category: 消息分组 (决定APP分组)
  #       order_type: 订单类型（仅订单消息）
  #       order_id: 订单ID （仅订单消息）
  #       guest_queue_id: （仅排号消息）
  #       queue_setting_id: （仅排号消息）
  #    }
  # }
  #

  def self.batch_device(message, channels)
    unless Rails.application.config.disable_app_notification

      Rails.logger.jpush.info(
          message.merge(
              channels: channels.map { |it| [it.os_type, it.j_push_channel_id] }
          ));
      # audience: JPush::Audience.build(registration_id: ['140fe1da9ea8759ac26', '191e35f7e0468fddb92']),

      begin

          client = JPush::JPushClient.new(Ddt::JPushConfig.app_key, Ddt::JPushConfig.master_secret)


          android_channel_ids =  channels.select{|channel| channel.os_type.to_sym == :android && !channel.is_oem?}.map(&:j_push_channel_id)
          ios_channel_ids = channels.select{|channel| channel.os_type.to_sym == :ios && !channel.is_oem?}.map(&:j_push_channel_id)
          if android_channel_ids.present? || ios_channel_ids.present?
            self.push_message(ios_channel_ids, android_channel_ids, message, Ddt::JPushConfig.app_key, Ddt::JPushConfig.master_secret, Ddt::JPushConfig.apns_production)
          end

          oem_android_channel_ids =  channels.select{|channel| channel.os_type.to_sym == :android && channel.is_oem?}.map(&:j_push_channel_id)
          oem_ios_channel_ids = channels.select{|channel| channel.os_type.to_sym == :ios && channel.is_oem?}.map(&:j_push_channel_id)
          if oem_android_channel_ids.present? || oem_ios_channel_ids.present?
            self.push_message(oem_ios_channel_ids, oem_android_channel_ids, message, Ddt::JPushConfig.oem_app_key, Ddt::JPushConfig.oem_master_secret, Ddt::JPushConfig.oem_apns_production)
          end
      rescue JPush::ApiConnectionException => e
          Rails.logger.jpush.error("#{e.message}\n#{e.backtrace}")

      rescue => e
          Rails.logger.jpush.error("#{e.message}\n#{e.backtrace}")
          raise e
      end
    end
  end

  def self.push_message(ios_channel_ids, android_channel_ids, message, app_key, master_secret, apns_production)
    client = JPush::JPushClient.new(app_key, master_secret)
    if android_channel_ids.present?
        android_pay_load = JPush::PushPayload.build(
          platform: JPush::Platform.build(android: true),
          audience: JPush::Audience.build(registration_id: android_channel_ids),
          notification: JPush::Notification.build(
            alert: message[:title],
            android: JPush::AndroidNotification.build(
              alert: message[:description],
              title: message[:title],
              builder_id: 1,
              extras: message[:custom_content])),
          message: JPush::Message.build(
            msg_content: message[:description],
            title: message[:title],
            content_type: "json",
            extras: message[:custom_content])
        )
        client.sendPush(android_pay_load)
    end


    if ios_channel_ids.present?
        ios_pay_load =  JPush::PushPayload.build(
          platform: JPush::Platform.build(ios: true),
          audience: JPush::Audience.build(registration_id: ios_channel_ids),
          notification: JPush::Notification.build(
            alert: message[:title],
            ios: JPush::IOSNotification.build(
              alert: message[:description],
              title: message[:title],
              badge: 1,
              sound: "/www/audio/default.mp3",
              extras: message[:custom_content])),
          message: JPush::Message.build(
            msg_content: message[:description],
            title: message[:title],
            content_type: "json",
            extras: message[:custom_content]),
            options:JPush::Options.build(
            sendno: 1,
            apns_production: apns_production.to_sym == :production))
        client.sendPush(ios_pay_load)
    end
  end
end