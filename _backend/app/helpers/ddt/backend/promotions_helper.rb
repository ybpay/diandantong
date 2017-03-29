module Ddt
  module Backend
    module PromotionsHelper
      def options_for_promotion_rule_types(promotion)
        existings = promotion.rules.map{|rule| rule.class.name }
        case promotion.class.name
        when "Ddt::OrderPromotion"
          promotion_type = :order
          if promotion.in_shop?
            all_rules = [
              Ddt::Promotion::Rules::Order::FirstOrderInShop,
              Ddt::Promotion::Rules::Order::ItemTotal,
              Ddt::Promotion::Rules::Order::OneUsePerUser,
              Ddt::Promotion::Rules::Order::PayMethod,
              Ddt::Promotion::Rules::Order::VipOnly,
            ]
          else
            all_rules = [
              Ddt::Promotion::Rules::Order::Combo,
              Ddt::Promotion::Rules::Order::FirstOrderInBranch,
              Ddt::Promotion::Rules::Order::ItemTotal,
              Ddt::Promotion::Rules::Order::OneUsePerUser,
              Ddt::Promotion::Rules::Order::Variant,
              Ddt::Promotion::Rules::Order::OrderInTimeRange,
              Ddt::Promotion::Rules::Order::PayMethod,
              Ddt::Promotion::Rules::Order::VipOnly,
            ]
          end
        when "Ddt::ProductPromotion"
          promotion_type = :order
          all_rules = [
            Ddt::Promotion::Rules::Order::Combo,
            # Ddt::Promotion::Rules::Order::FirstOrderInBranch,
            # Ddt::Promotion::Rules::Order::ItemTotal,
            # Ddt::Promotion::Rules::Order::OneUsePerUser,
            Ddt::Promotion::Rules::Order::Variant,
            Ddt::Promotion::Rules::Order::OrderInTimeRange,
            # Ddt::Promotion::Rules::Order::PayMethod,
            # Ddt::Promotion::Rules::Order::VipOnly,
          ]
        when "Ddt::EventPromotion"
          promotion_type = :event
          if promotion.in_shop?
            all_rules = [
              Ddt::Promotion::Rules::Event::FirstFollow,
              Ddt::Promotion::Rules::Event::FirstOrderInShop,
              Ddt::Promotion::Rules::Event::FirstOrderTodayInShop,
              Ddt::Promotion::Rules::Event::ItemTotal,
              Ddt::Promotion::Rules::Event::UserContinuousSignCount,
              Ddt::Promotion::Rules::Event::UserSignIn,
              Ddt::Promotion::Rules::Event::UserSignRecordsCount,
              Ddt::Promotion::Rules::Event::UserActiveVip,
              Ddt::Promotion::Rules::Event::VipBirthday,
              Ddt::Promotion::Rules::Event::VipRecharge,
              Ddt::Promotion::Rules::Event::TimesLimit,
              Ddt::Promotion::Rules::Event::ShareToFriendCircle,
              Ddt::Promotion::Rules::Event::VipOnly,
              Ddt::Promotion::Rules::Event::UserTotalAmount,
              Ddt::Promotion::Rules::Event::FromSharedUserRecharge,
            ]
          else
            all_rules = [
              Ddt::Promotion::Rules::Event::FirstOrderInBranch,
              Ddt::Promotion::Rules::Event::FirstOrderTodayInBranch,
              Ddt::Promotion::Rules::Event::ItemTotal,
            ]
          end
        end
        rule_names = all_rules.map(&:name).reject{ |rule| existings.include? rule }
        options = rule_names.map { |name| [ I18n.t("promotion.rules.#{promotion_type}.#{name.demodulize.underscore}"), name] }
        options_for_select(options)
      end

      def options_for_promotion_action_types(promotion)
        case promotion.class.name
        when "Ddt::OrderPromotion"
          promotion_type = :order
          if promotion.in_shop?
            all_actions = [
              Ddt::Promotion::Actions::Order::CreateAdjustment,
              Ddt::Promotion::Actions::Order::FreeShipping
            ]
          else
            all_actions = [
              Ddt::Promotion::Actions::Order::CreateAdjustment,
              Ddt::Promotion::Actions::Order::FreeShipping,
              # Ddt::Promotion::Actions::Order::CategoryDiscount,
              # Ddt::Promotion::Actions::Order::ItemDiscount,
              # Ddt::Promotion::Actions::Order::ItemReduce,
              # Ddt::Promotion::Actions::Order::ItemSecondHalfOff,
            ]
          end
        when "Ddt::ProductPromotion"
          promotion_type = :order
          all_actions = [
            # Ddt::Promotion::Actions::Order::CreateAdjustment,
            # Ddt::Promotion::Actions::Order::FreeShipping,
            Ddt::Promotion::Actions::Order::CategoryDiscount,
            Ddt::Promotion::Actions::Order::ItemDiscount,
            Ddt::Promotion::Actions::Order::ItemReduce,
            Ddt::Promotion::Actions::Order::ItemSecondHalfOff,
          ]
        when "Ddt::EventPromotion"
          promotion_type = :event
          if promotion.in_shop?
            all_actions = [
              Ddt::Promotion::Actions::Event::GetCoupon,
              Ddt::Promotion::Actions::Event::GetVoucher,
              Ddt::Promotion::Actions::Event::GetCredits,
              Ddt::Promotion::Actions::Event::GetCreditsPercent,
            ]
          else
            all_actions = [
              Ddt::Promotion::Actions::Event::GetCredits,
              Ddt::Promotion::Actions::Event::GetCreditsPercent,
            ]
          end
        end
        action_names = all_actions.map(&:name)
        options = action_names.map { |name| [ I18n.t("promotion.actions.#{promotion_type}.#{name.demodulize.underscore}"), name] }
        options_for_select(options)
      end

      def option_for_calculator_types(promotion_action)
        calculators = [
          Ddt::Calculator::Order::FlatPercent,
          Ddt::Calculator::Order::FlatRate,
          Ddt::Calculator::Order::FlatReduce,
          Ddt::Calculator::Order::TieredFlatRate,
          Ddt::Calculator::Order::TieredPercent,
          Ddt::Calculator::Order::TieredReduce,
        ]
        options_from_collection_for_select(calculators, :to_s, :description, promotion_action.calculator.type)
      end

      def calculator_hint(calculator)
        type = calculator.class.name.split("::").last(2).join('_').underscore.to_sym
        {
          order_flat_percent: "订单总价折扣",
          order_flat_rate: "订单满足条件时， 如条件为100≤订单价格≤1000时， 订单价格将会是设定好的统一的价格进行支付",
          order_flat_reduce: "订单总价减免",
          order_tiered_flat_rate: "如果价格不在梯度内，订单价格会按照基础价格进行支付 例如设置了两个阶梯订单价格100和200，在用户下单价格在100和200之间时，用户支付时会按照第一个统一价格支付，在订单价格大于200时，将会按照第二个统一价格支付",
          order_tiered_percent: "如果价格不在梯度内，订单价格会按照基础折扣进行支付 例如设置了两个阶梯订单价格100和200，在用户下单价格在100和200之间时，用户支付时会按照第一个折扣支付，在订单价格大于200时，将会按照第二个折扣支付",
          order_tiered_reduce: "如果价格不在梯度内，订单价格会按照基础减免进行支付 例如设置了两个阶梯订单价格100和200，在用户下单价格在100和200之间时，用户支付时会按照第一个减免支付，在订单价格大于200时，将会按照第二个减免支付",
          line_item_flat_percent: "产品折扣",
          line_item_flat_rate: "产品统一价格",
          line_item_flexi_rate: "如第一份：10， 第二份及之后： 8，最多数量4，第一份产品或套餐将会是10元，第二、三、四份会是8元，当第四份之后会按照原价结算",
          line_item_second_half_off: ""
        }[type]
      end

    end
  end
end