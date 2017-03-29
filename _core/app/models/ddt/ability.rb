#encoding: utf-8
module Ddt
  class Ability
    include CanCan::Ability
    def initialize(account)
      alias_action :create, :read, :update, :destroy, :show, :index, :new, :to => :crud
      @account = account || Account.new
      @account_manage_branch_ids = @account.manage_branch_ids
      @account.roles.each do |role|
        if role.builtin?
          send(role.name.to_sym)
        else
          custom_role(role)
        end
      end
      can :show, Account, :id => @account.id
      can :manage, Ckeditor::Picture, :assetable_id => @account.id
      can :access, :ckeditor
      can :wechat_users, WechatAccount
      can :welcome, Shop
    end


    def boss_condition
      {:shop_id => @account.shop_id}
    end

    def base_condition
      { :branch_id => @account_manage_branch_ids, :shop_id=> @account.shop_id }
    end

    def admin
      can :manage, :all
    end

    def boss
      can [:update_sale_employee], Shop, :id => @account.shop_id
      can [:show, :dashboard, :edit, :update, :module_index, :copy_link,
        :show_search_word, :edit_search_word, :update_search_word, :config_guide], Shop, :id => @account.shop_id
      can :manage, boss_list, boss_condition
      can :manage, [Statistic, BusinessStatistic]
      can [:index, :show], ServiceProduct, :is_offline => false
      can [:new, :create, :index], Withdraw
      can [:sidebar], 'order_promotion'
      can [:sidebar], 'event_promotion'
      can [:sidebar], statistic_list
    end

    def worker
      can [:index, :show, :update, :edit], Branch, id: @account_manage_branch_ids
      can :manage, worker_list, base_condition
      can [:new, :create], worker_list, :shop_id => @account.shop_id
      # 由于worker 对于 Account 的权限比较复杂，这里权限放得较宽，具体请查看 Account 类的 manage_by_worker
      can [:index, :new, :create, :edit, :update, :edit_password, :update_password, :destroy], Account, shop_id: @account.shop_id
      can [:index], Role, name: %w[cashier waiter chef cook deliveryman], shop_id: @account.shop_id
      can [:index], Role, builtin: 0, shop_id: @account.shop_id
      can [:sidebar], statistic_list
    end

    def waiter
      manage_self_account
    end

    def cashier
      manage_self_account
    end

    def accountant
      manage_self_account
      can :manage, [Ddt::Statistic]
      can :sidebar, statistic_list
    end

    def deliveryman
      manage_self_account
      can :show, Branch, :id => @account_manage_branch_ids
      can [:assigned,:index, :show, :start, :ship], OrderService::Order::Delivery, :shop_id => @account.shop_id, :shipment => {:delivery_man_id => @account.id}
    end

    def cook
      manage_self_account
    end

    def chef
     cook
    end

    def vip_info_manager
      can [:manage], VipInfo, :shop_id => @account.shop_id
    end

    def queue_waiter
      can [:manage], queue_list, :shop_id => @account.shop_id, :branch_id => @account_manage_branch_ids
    end

    def manage_self_account
      can [:show, :edit, :update, :edit_password, :update_password], Account, :id => @account.id
    end

    def custom_role(role)

    end

    def boss_list
      [ Account,
        BaseQrCodeScene,
        VipLevel,
        VipInfo,
        BaseUser,
        BranchType,
        BranchGroup,
        Branch,
        WechatAccount,
        Role,
        Zone,
        ShopCardWallet,
        ShopCreditsWallet,
        BranchCardWallet,
        BranchCreditsWallet,
        UserCardWallet,
        UserCreditsWallet,
        WalletLog,
        PaymentMethod,
        AlipayMethod,
        BaidupayMethod,
        WechatpayMethod,
        WechatpayMethodLegacy,
        WechatpayMethodV336,
        WechatShareRecord,
        BranchSlider,
        SignRecord,
        EmailSetting,
        MerchantApply,
        Tag,
        ExchangeCode,
        ServiceProductOrder,
        ShortMessageSetting,
        CallSetting,
        CreditsSetting,
        OnePage,
        TableColor,
        PayMethodSetting,
        PayMethod,
        GiftReason,
        RechargeProduct,
        CollectionWallet,
        Shift,
        EssentialProduct,
        ShakeAround::ApplyLog,
        ShakeAround::Device,
        ShakeAround::ShakeInfo,
        CsBranchBinding
      ] + wechat_list + coupon_list  + custom_info_list + worker_list
    end

    def worker_list
      [
        OrderService::Order::Base,
        OrderService::Order::Delivery,
        OrderService::Order::EatInHall,
        OrderService::Order::Fastfood,
        OrderService::Order::Groupon,
        OrderService::Order::Payment,
        OrderService::Order::Recharge,
        OrderService::Order::Reservation,
        ShortMessage,
        Comment,
        Payment,
        PaymentLog,
        FormElement,
        Tag,
        ExchangeCode,
        PayMethodSetting,
        TargetsCustom,
        Target,
        WaiterServiceItem,
        Location,
        LineItemTracePoint,
        EatInHallSetting,
        EssentialProduct,
      ] + product_list + table_list + delivery_list + reservation_list + promotion_list + printer_list + queue_list
    end

    private
    def wechat_list
      [ Material,
        Article,
        Event,
        WechatMenu,
        KeywordsThirdPartyInterface]
    end

    def coupon_list
      [ GrouponVersion,
        Groupon,
        VoucherVersion,
        Voucher,
        CouponVersion,
        Coupon,]
    end

    def product_list
      [ Product,
        Variant,
        VariantImage,
        OptionType,
        Category,
        ItemNote,
        Combo,
        ComboItem ]
    end

    def table_list
      [ Table,
        TableZone,
        ReservationTimePoint
      ]
    end

    def delivery_list
      [ DeliveryZone,
        DeliverySetting,
        DeliveryRange
      ]
    end

    def reservation_list
      [ReservationSetting]
    end

    def promotion_list
      [ EventPromotion,
        OrderPromotion,
        PromotionRule,
        PromotionAction]
    end

    def printer_list
      [ Printer,
        PrintRecord,
        PrintSetting,]
    end

    def custom_info_list
      [ CustomWeixinInfo,
        HomeHotLink,
        HomeUsableLink]
    end

    def queue_list
      [ ArrangingSetting,
        QueueSetting,
        GuestQueue,]
    end

    def statistic_list
      [
        'orders_statistic',
        'product_statistic',
        'table_statistic',
        'user_statistic',
        'business_statistic',
        'coupon_statistic',
        'worker_statistic',
        'finance_statistic'
      ]
    end

  end
end
