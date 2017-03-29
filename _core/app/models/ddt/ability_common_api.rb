module Ddt
  class AbilityCommonApi
    include CanCan::Ability
    def initialize(account)
      @account = account || Account.new
      @account_manage_branch_ids = @account.manage_branch_ids
      @account.roles.each do |role|
        send(:try, role.name.to_sym) if role.builtin?
      end
    end

    def base_condition
      { :branch_id => @account_manage_branch_ids, :shop_id => @account.shop_id }
    end

    def admin
      can :manage, :all
    end

    def boss
      can :manage, :all
    end

    def all
      # 由于worker 对于 Account 的权限比较复杂，这里权限放得较宽，具体请查看 Account 类的 manage_by_worker
      can :manage, Account
      can [:add_combo_package], Combo
      can [:index, :create, :pass, :requeue, :accept, :cancel, :notify, :reprint, :print_pre_order, :show], GuestQueue
      can [:index, :update], Product
      can [:index, :search, :show, :open, :clear], Table
      can [:create, :update], VariantPackage
      # order
      can [:show, :confirm, :hasten, :reprint, :append, :active_line_items, :subtract], order_classes
      can [:cancel, :complete, :change_vip_info, :unbind_vip_info, :card_deduction], order_classes
      can [:assign_delivery_man, :start_delivery, :finish_delivery], OrderService::Order::Delivery
      can [:create, :change_table, :merge_table], OrderService::Order::EatInHall
      can [:create], OrderService::Order::Payment
      can [:create, :clear, :paid_all, :paid, :get_pay_online, :pay_by_seller_scan, :show], OrderService::PayItem
    end

    def worker
      all
    end

    def waiter
      manage_self_account
      can [:add_combo_package], Combo
      can [:index], Product
      can [:index, :search, :show, :open, :clear], Table
      can [:create, :update], VariantPackage
      # order
      can [:show, :confirm, :hasten, :reprint, :append, :active_line_items, :subtract], order_classes
      can [:create, :change_table, :merge_table], OrderService::Order::EatInHall
    end

    def cashier
      manage_self_account
      can [:add_combo_package], Combo
      can [:index], Product
      can [:index, :search, :show, :open, :clear], Table
      can [:create, :update], VariantPackage
      # order
      can [:show, :confirm, :hasten, :reprint, :append, :active_line_items, :subtract], order_classes
      can [:cancel, :complete, :change_vip_info, :unbind_vip_info, :card_deduction], order_classes
      can [:create, :change_table, :merge_table], OrderService::Order::EatInHall
      can [:create, :clear, :paid_all, :paid, :get_pay_online, :pay_by_seller_scan, :show], OrderService::PayItem
    end

    def deliveryman
      manage_self_account
      can [:index], Product
      can [:index, :search, :show], Table
      # order
      can [:show], order_classes
      can [:assign_delivery_man, :start_delivery, :finish_delivery], OrderService::Order::Delivery
    end

    def queue_waiter
      can [:index, :create, :pass, :requeue, :accept, :cancel, :notify, :reprint, :print_pre_order, :show], GuestQueue
      can [:index], Product
      can [:index, :search, :show], Table
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

    def manage_self_account
      can [:show, :edit, :update, :edit_password, :update_password], Account, :id => @account.id
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
  end
end
