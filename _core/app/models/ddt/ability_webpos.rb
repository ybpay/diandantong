module Ddt
  class AbilityWebpos
    include Ddt::CanCanCompatibility


    def initialize(account)
      initialize_rules
      @account = account || Account.new
      @account_manage_branch_ids = @account.manage_branch_ids
      @account.roles.each do |role|
        if role.builtin?
          send(role.name.to_sym)
        else
          custom_role(role)
        end
      end
    end

    def base_condition
      { :branch_id => @account_manage_branch_ids, :shop_id=> @account.shop_id }
    end

    def admin
      can :manage, :all
    end

    def boss
      can :manage, :all
    end

    def share_by_worker_and_cashier
      can_view_account
      can [:index, :show, :bill_center, :waiter_names], Ddt::Branch
      # 允许查看报表


      with_options base_condition do |a|
        a.can [:available, :exchange_by_code, :exchange_by_id], Groupon
        a.can [:search, :available, :exchange_by_code, :exchange_by_id], Voucher

        a.can [:index, :show], OrderService::Order::Base
        a.can :manage, OrderService::LineItem
        a.can :manage, Product
        a.can :manage, Variant

        a.can [:create, :index, :pass, :accept, :cancel, :notify, :show, :reprint, :bill, :print_pre_order, :pre_order_bill], GuestQueue
        a.can [:index, :reprint], Printer
      end
      can [:exchange, :recharge], UserCardWallet
      can [:exchange], UserCreditsWallet
      can [:search, :available, :apply, :exchange_by_code, :find_by_code], [BaseCoupon, Coupon, Groupon, Voucher]

      # ---
      can [:clear, :read], :card
    end

    def worker
      share_by_worker_and_cashier
      with_options base_condition do |a|
        a.can [:index, :show, :open, :get_filtered_tables, :get_changed_tables, :get_reservation_tables, :clear, :check_out, :cancel_check_out, :update_guest_num, :force_clear], Table
        a.can :manage, OrderService::Order::Base
        a.can :manage, order_classes
      end
      can :manage, VipInfo
    end

    def cashier
      share_by_worker_and_cashier
      can [:open_shift, :close_shift, :get_shift, :print_shift], Branch
      can [:create, :show, :update, :get_by_scan_code, :wallet_logs, :merge, :become, :reject], VipInfo
      can :manage, OrderService::PayItem, :branch_id => @account_manage_branch_ids, :shop_id=> @account.shop_id
      can [:bosses, :bosses_and_workers, :workers, :authorization], Account, shop_id: @account.shop_id
      with_options base_condition do |a|
        a.can [:index, :show, :get_filtered_tables, :get_changed_tables, :get_reservation_tables, :clear, :check_out, :cancel_check_out, :update_guest_num, :force_clear], Table
        a.can [:show, :pay, :get_pay_online, :pay_by_seller_scan, :change_vip_info, :unbind_vip_info,
               :credits_deduction, :card_deduction, :privilege_discount, :privilege_reduction, :privilege_free,
               :moling, :cancel_privilege_discount, :cancel_privilege_reduction, :cancel_privilege_free, :cancel_moling,
              :apply_coupon, :rollback_coupon, :apply_voucher, :rollback_voucher,
              :bill, :create_pay_items, :clear_pay_items, :pay_all_pay_items, :assign_delivery_man, :change_to_eat_in_hall, :anti_settlement],
              order_classes
        # never use cannot here
      end

    end

    def waiter
      can_view_account
      can [:index, :show, :waiter_names], Branch
      can [:bosses, :bosses_and_workers, :workers, :authorization], Account, shop_id: @account.shop_id
      with_options base_condition do |a|
        a.can [:index, :show], OrderService::Order::Base
        a.can :manage, order_classes
        # a.can [:create, :cancel, :confirm, :complete, :update, :append, :active_line_items, :subtract,
        #        :bind_table, :change_table, :merge_table, :bind_reservation_order, :call_customer]
        # a.cannot [
        #           :confirm,
        #           :complete,
        #           :change_to_eat_in_hall,
        #           :apply_coupon,
        #           :apply_voucher,
        #           :privilege_discount,
        #           :privilege_reduction,
        #           :privilege_free,
        #           :assign_delivery_man,
        #           :bind_table]
        a.can [:create, :index, :pass, :accept, :notify, :show, :reprint, :bill, :print_pre_order, :pre_order_bill], GuestQueue
        a.can [:index], Printer
        a.can [:index, :show, :open, :get_filtered_tables, :get_changed_tables, :get_reservation_tables, :clear, :check_out, :cancel_check_out, :update_guest_num], Table
        a.can :manage, Variant
      end
    end

    def deliveryman
    end

    def cook
      can_view_account
      can [:index, :show], Branch
      with_options base_condition do |a|
        a.can [:index, :mark_cooking, :mark_cooked, :mark_canceled, :check_config], OrderService::LineItemTracePoint
      end
    end

    def chef
      cook
      with_options base_condition do |a|
        a.can [:index,:pending_counts, :cooks, :mark_cooking, :mark_cooked, :mark_canceled, :check_config], OrderService::LineItemTracePoint
      end
    end

    def vip_info_manager
      can [:manage], VipInfo, :shop_id => @account.shop_id
    end

    def queue_waiter
      can_view_account
      can [:index, :show], Branch
      with_options base_condition do |a|
        a.can [:manage], GuestQueue
      end
    end

    #会计无需登陆webpos
    def accountant

    end

    def custom_role(role)

    end

    # CanCan::Rule : actions, base_behavior, block, conditions, match_all, subjects
    def to_hash
      return [] if @account.id.blank?
      # 邮件里看到 @rules 会空，原因未知，这里加一层保护
      if @rules.present?
        @rules.map do |rule|
          subjects = rule.subjects.map {|s| s.to_s.demodulize.underscore}
          {actions: rule.actions, base_behavior: rule.base_behavior, conditions: rule.conditions, subjects: subjects}
        end
      else
        []
      end
    end

    private

    def order_classes
      [
        "base_order",
        OrderService::Order::Delivery,
        OrderService::Order::EatInHall,
        OrderService::Order::Fastfood,
        OrderService::Order::Groupon,
        OrderService::Order::Payment,
        OrderService::Order::Reservation
      ]
    end

    def can_view_account
      can :show, Account, id: @account.id
    end
  end
end
