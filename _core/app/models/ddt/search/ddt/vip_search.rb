module Ddt
  class VipSearch < Ddt::BaseSearch
    attr_accessor :name, :sex_eq, :vip_level_id_eq, :total_amount_gteq, :total_amount_lteq, :placed_orders_count_gteq, :placed_orders_count_lteq, :order_within_days, :consume_times_gteq, :become_within_days, :from_branch_id_eq, :birthday_gteq, :birthday_lteq, :updated_at_lteq,
                           :updated_at_gteq, :total_recharge_money_gteq, :total_recharge_money_lteq, :vip_card_consume_amount_gteq, :vip_card_consume_amount_lteq, :recharge_times_gteq, :recharge_times_lteq
    
    class << self
      def to_label(params)
        labels = []
        params.each_pair do |k, v|
          next if v.blank?
          case k.to_sym
          when :sex_eq
            labels << ('femail' == v ? '性别为女' : '性别为男')
          when :vip_level_id_eq
            vip_level = Ddt::VipLevel.find_by(id: v)
            labels << "会员级别为#{vip_level.name}" if vip_level.present?
          when :from_branch_id_eq
            branch = Ddt::Branch.find_by(id: v)
            labels << "办卡门店为#{branch.name}" if branch.present?
          when :total_amount_gteq
            labels << "累计消费大于等于#{v}"
          when :total_amount_lteq
            labels << "累计消费小于等于#{v}"
          when :placed_orders_count_gteq
            labels << "累计下单数大于等于#{v}"
          when :placed_orders_count_lteq
            labels << "累计下单数小于等于#{v}"
          when :order_within_days
            labels << "最近#{v}天内下过单"
          when :consume_times_gteq
            labels << "累计消费次数大于等于#{v}次"
          when :become_within_days
            labels << "最近#{v}天内新增的会员"
          when :updated_at_lteq
            labels << "最后使用记录 结束时间#{v}"
          when :updated_at_gteq
            labels << "最后使用记录 开始时间#{v}"
          when :birthday_gteq
            labels << "生日大于等于#{v}"
          when :birthday_lteq
            labels << "生日小于等于#{v}"
          when :total_recharge_money_gteq
            labels << "总充值金额大于等于#{v}"
          when :total_recharge_money_lteq
            labels << "总充值金额小于等于#{v}"
          when :vip_card_consume_amount_gteq
            labels << "会员卡消费金额大于等于#{v}"
          when :vip_card_consume_amount_lteq
            labels << "会员卡消费金额小于等于#{v}"
          when :recharge_times_gteq
            labels << "充值次数大于等于#{v}"
          when :recharge_times_lteq
            labels << "充值次数小于等于#{v}"
          end
        end
        labels.join('，  ')
      end
    end

    def self.valid?(params)
      if params[:updated_at_lteq].present? && params[:updated_at_gteq].present?
        if Time.parse(params[:updated_at_lteq]) - Time.parse(params[:updated_at_gteq]) > 30.days
          return false
        end
      end
      return true
    end

  end
end
