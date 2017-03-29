module Ddt
  module BillTemplate
    module Tag
      class If < Tag::Base
        tag_attr :type, :string, default: ''
        tag_attr :present, :string, default: ''
        tag_attr :blank, :string, default: ''
        tag_attr :item_present, :string, default: ''
        tag_attr :paid, :string, default: ''
        tag_attr :canceled, :string, default: ''
        tag_attr :vip, :string, default: ''
        tag_attr :from, :string, default: ''
        tag_attr :lstrip, :boolean, default: false

        def render(object=nil, item=nil)
          condition =
            (type.blank? || type == object.type_str) &&
            (present.blank? ||
              (
                present_collection.include?(present.to_sym) &&
                object.respond_to?(present) &&
                object.send(present).present?
              ) ||
              (
                amount_present_collection.include?(present.to_sym) &&
                object.respond_to?(present) &&
                object.send(present).present? && object.send(present) != 0
              )
            ) &&
            (item_present.blank? ||
              (
                item_present_collection.include?(item_present.to_sym) && item.present? &&
                item.respond_to?(item_present) &&
                item.send(item_present).present?
              )
            ) &&
            (paid.blank? || (paid == 'true' && object.paid? )) &&
            (canceled.blank? || (canceled == 'true' && object.is_canceled? )) &&
            (vip.blank? || (vip == 'true' && object.vip_info.present? )) &&
            (from.blank? || (from == 'Wechat' && object.is_FromWechat? )) &&
            (blank.blank? ||
              (
                present_collection.include?(blank.to_sym) &&
                object.respond_to?(blank) &&
                object.send(blank).blank?
              ) ||
              (
                amount_present_collection.include?(blank.to_sym) &&
                object.respond_to?(blank) &&
                (object.send(blank).blank? || object.send(blank) == 0)
              )
            )
          condition ? content : ''
        end

        def present_collection
          [
            :note,
            :waiter_name,
            :guest_num,
            :form_contents,
            :adjustments,
            :pay_items,
            :line_items,
            :user,
            :closed_at,
            :shift_closed_at,
            :pre_cash_amount,
            :vip_card_no,
            :tick_account
          ]
        end

        def amount_present_collection
          [:tax_total, :cash_amount, :recharge_amount, :not_actual_amount, :actual_amount, :moling_amount]
        end

        def item_present_collection
          [
            :item_note,
          ]
        end
      end
    end
  end
end
