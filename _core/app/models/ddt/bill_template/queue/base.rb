module Ddt
  module BillTemplate
    module Queue
      class Base < BillTemplate::Base
        attr_accessor :guest_queue, :printer, :bill_operator
        delegate :queue_setting, :branch, :shop, to: :guest_queue
        delegate :guest_no, :guest_num, :guest_num_at_front, to: :guest_queue
        def initialize(guest_queue:nil, printer:nil,bill_operator:nil)
          @guest_queue = guest_queue
          @printer = printer
          @bill_operator = bill_operator
        end

        def self.virtual_guest_queue_of_branch(branch)
          pre_order_itemable_1 = OpenStruct.new(
            to_line_itemable: OpenStruct.new(
              item_name: "宫爆鸡丁",
              item_price: 10.00,
              item_quantity: 2,
              item_subtotal: 20.00,
              item_note: "加辣",
              )
            )
          pre_order_itemable_2 = OpenStruct.new(
            to_line_itemable: OpenStruct.new(
              item_name: "鱼香茄子",
              item_price: 10.00,
              item_quantity: 2,
              item_subtotal: 20.00,
              item_note: "加辣",
              )
            )
          guest_queue = OpenStruct.new({
            branch: branch,
            shop: branch.shop,
            waited_time_str: '10分10秒',
            created_at: 1.minute.ago,
            queue_setting: OpenStruct.new(name: "2人桌"),
            guest_no: 'A003',
            guest_num: 2,
            guest_num_at_front: 3,
            user: nil,
            qr_code_type: :snap_wechat_qr_code,
            qr_code_image: "http://open.weixin.qq.com/qr/code/?username=ddt",
            pre_order_itemables: [pre_order_itemable_1, pre_order_itemable_2],
          })
        end

        def self.preview(branch)
          printer = Printer::Normal.new(print_spec: "58", use_scene: :queue)
          guest_queue = virtual_guest_queue_of_branch(branch)
          self.new(guest_queue: guest_queue, printer: printer).render
        end

        private
        def replace_if_tag(text)
          replaced_text = text
          if_tags = TagHelper.scan_tag(text, "if")
          if_tags.each do |tag|
            replaced_text = replaced_text.sub(tag.body, tag.render(guest_queue))
          end
          replaced_text
        end

        def branch_name
          branch.name
        end

        def queue_name
          queue_setting.name
        end

        def bill_operator_name
          bill_operator.try(:name)
        end

        def guest_created_at
          guest_queue.created_at.strftime("%F %H:%M")
        end

        def guest_waited_time
          guest_queue.waited_time_str
        end

        def queue_qrcode
          if (printer.is_feie? || printer.is_fengchi?) && guest_queue.qr_code_type == :base_qr_code
            "<QR>#{guest_queue.weixin_view_url}</QR>"
          else
            qr_code_image_url = guest_queue.qr_code_image
            "<QRI>#{qr_code_image_url}</QRI>\n<C>2小时内扫描此二维码有效</C>" if qr_code_image_url.present?
          end
        end

        def support_info
          if shop.is_oem?
            "<C>#{shop.support_brand_name}提供技术支持，技术支持热线电话#{shop.support_telephone}</C>"
          else
            "<C>点单通提供技术支持，技术支持热线电话40012345678</C>"
          end
        end

        def inline_value_names
          base_inline_value_names +
          [:branch_name, :queue_name, :guest_no, :guest_num, :guest_num_at_front,
            :guest_created_at, :guest_waited_time, :queue_qrcode, :support_info, :bill_operator_name]
        end
      end
    end
  end
end