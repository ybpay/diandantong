# encoding: utf-8
module Ddt
  module SystemMaterial
    class Scene < ::Ddt::SystemMaterial::Base
      attr_reader :scene_id
      def initialize(message_reception, scene_id)
        @message_reception = message_reception
        @scene_id = scene_id
      end

      def build_message
        wechat_qr_code_scene = shop.wechat_qr_code_scenes.find_by_scene_id(scene_id)
        if wechat_qr_code_scene.present?
          if wechat_qr_code_scene.is_snap?
            # 临时二维码
            if wechat_qr_code_scene.is_queue?
              # 排号临时二维码
              guest_queue = wechat_qr_code_scene.owner
              response_news_msg([{
                title: '排号提醒：点击本消息获取实时排号状态消息推送',
                description: "重要提醒：点击本消息后系统会以微信消息的形式，提前#{guest_queue.queue_setting.notify_number_in_advance}桌实时推送排号进展消息。\n同时，您可以点击本消息提前点菜，节约等待时间哦。\n\n门店名称：#{guest_queue.branch.name}\n排队号码：#{guest_queue.queue_setting.name} #{guest_queue.guest_no}\n前面等待：#{guest_queue.guest_num_at_front}桌\n排队状态：#{guest_queue.workflow_state_name}",
                pic_url: "",
                url: guest_queue.weixin_bind_url
              }])
            end
          else
            # 永久二维码
            if wechat_qr_code_scene.is_branch_message?
              # 门店消息
              branch = wechat_qr_code_scene.branch
              if branch.present?
                response_news_msg([{
                  title: "欢迎关注#{branch.name}，点击进入",
                  description: branch.introduction_decoder,
                  pic_url: branch.rect_image.medium.url,
                  url: branch_url(branch)
                }])
              end
            elsif wechat_qr_code_scene.is_queue_message?
              # 门店排号消息
              branch = wechat_qr_code_scene.branch
              if branch.present?
                response_news_msg([{
                  title: "#{branch.name}，点击进入排号",
                  description: branch.introduction_decoder,
                  pic_url: branch.rect_image.medium.url,
                  url: Ddt::LinkResource.new(shop: shop, branch: branch).branch_queue_url
                }])
              end
            elsif wechat_qr_code_scene.is_material_message?
              # 素材消息
              material = wechat_qr_code_scene.material
              message_reception.create_response_from_material(material) if material.present?
            elsif wechat_qr_code_scene.is_fastfood_message?
              # 门店快餐消息
              branch = wechat_qr_code_scene.branch
              if branch.present?
                response_news_msg([{
                  title: "#{branch.name}，点击进入快餐",
                  description: branch.introduction_decoder,
                  pic_url: branch.rect_image.medium.url,
                  url: Ddt::LinkResource.new(shop: shop, branch: branch).branch_fastfood_url
                }])
              end
            end
          end
        end
      end

    end
  end
end
