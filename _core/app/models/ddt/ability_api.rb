module Ddt
  class AbilityApi
    include CanCan::Ability

    def initialize(account)
      @account = account || Ddt::Account.new
      @account.roles.each do |role|
        sym = role.name.to_sym
        if role.builtin?
          send(sym) if respond_to? sym
        else
          custom_role(role)
        end
      end
    end

    def base_condition
      { :branch_id => @account.manage_branch_ids, :shop_id=> @account.shop_id }
    end

    def admin
      can :manage, :all
    end

    def boss
      can :manage, :all
    end

    def worker
      can [:login_app], Ddt::Shop
      can [:show, :update, :statistics], Ddt::Branch, { id: manage_branch_ids }
      can [:index, :show], Ddt::VipInfo, {shop_id: @account.shop_id}
      can [:index, :show], Ddt::VipLevel, {shop_id: @account.shop_id}
      can [:index, :show], Ddt::Zone, {shop_id: @account.shop_id}
      can [:index, :show], Ddt::BranchType, {shop_id: @account.shop_id}
      can [:index, :show], Ddt::BranchGroup, {shop_id: @account.shop_id}
      with_options base_condition do |a|
        a.can [:index], Ddt::WaiterServiceItem
        a.can [:index, :show], Ddt::Category
        a.can [:index, :show], Ddt::Combo
        a.can [:index, :create, :show, :accept, :pass, :cancel, :requeue, :notify, :reprint, :print_pre_order], Ddt::GuestQueue

        a.can [:index, :show, :update, :create,
               :pay, :confirm, :complete, :cancel, :place, :hasten, :ship, :anti_settlement], order_classes
        a.can [:index, :create, :destroy, :show, :update], Ddt::Product
        a.can [:show, :index, :pass, :accept], Ddt::QueueSetting
        a.can [:index, :show], Ddt::TableZone
        a.can [:index, :show, :open, :order, :clear, :pay, :cancel], Ddt::Table
        a.can [:show, :index, :update], Ddt::Variant
        a.can [:show, :update], Ddt::ExchangeCode
        a.can [:index], Ddt::Printer

      end
    end

    def waiter_and_cashier
      can [:login_app], Ddt::Shop
      can [:show], Ddt::Branch, { id: @account.manage_branch_ids }
      can [:index, :show], Ddt::VipInfo, {shop_id: @account.shop_id}
      can [:index, :show], Ddt::VipLevel, {shop_id: @account.shop_id}
      with_options base_condition do |a|
        a.can [:index, :show], Ddt::BranchType
        a.can [:index, :show], Ddt::BranchGroup
        a.can [:index, :show], Ddt::Zone
        a.can [:index], Ddt::WaiterServiceItem
        a.can [:index, :show], Ddt::Category
        a.can [:index, :show], Ddt::Combo
        a.can [:index, :create, :show, :accept, :pass, :cancel, :requeue, :notify, :reprint, :print_pre_order], Ddt::GuestQueue
        a.can :manage, order_classes
        # a.can [:index, :show, :update, :create,
        #        :pay, :confirm, :complete, :cancel, :hasten, :ship], order_classes
        a.can [:index, :show], Ddt::Product
        a.can [:show, :index, :pass, :accept], Ddt::QueueSetting
        a.can [:index, :show], Ddt::TableZone
        a.can [:index, :show, :open, :order, :clear, :pay, :cancel], Ddt::Table
        a.can [:show, :index], Ddt::Variant
        a.can [:show, :update], Ddt::ExchangeCode
        a.can [:index], Ddt::Printer
      end
    end

    # TODO 将来需要配合APP一起调整好界面与权限
    def waiter
      waiter_and_cashier
      with_options base_condition do |a|
        # a.can [:place], order_classes
      end
    end

    def cashier
      waiter_and_cashier
      with_options base_condition do |a|
        # a.can [:cash], order_classes
      end
    end

    def deliveryman
      can [:login_app], Ddt::Shop
      can :show, Ddt::Branch, { id: manage_branch_ids }
      with_options base_condition do |a|
        a.can [:index, :show, :ship, :pay], order_classes, :type => 'Ddt::OrderService::Order::Delivery'
      end
    end

    def vip_info_manager
      can [:manage], Ddt::VipInfo, :shop_id => @account.shop_id
    end

    def queue_waiter
      can [:login_app], Ddt::Shop
      can :show, Ddt::Branch, { id: manage_branch_ids }
      with_options base_condition do |a|
        a.can [:show, :index, :pass, :accept], Ddt::QueueSetting
        a.can [:index, :create, :show, :accept, :pass, :cancel, :requeue, :notify, :reprint, :print_pre_order], Ddt::GuestQueue
      end
    end

    def custom_role(role)

    end

    private
    def manage_branch_ids
      @manage_branch_ids || @manage_branch_ids = @account.manage_branch_ids
    end

    def order_classes
      [
          "base_order",
          Ddt::Order,
          Ddt::EatInHallOrder,
          Ddt::FastfoodOrder,
          Ddt::DeliveryOrder,
          Ddt::ReservationOrder,
          Ddt::PaymentOrder,
          Ddt::OrderService::Order::Base,
          Ddt::OrderService::Order::Delivery,
          Ddt::OrderService::Order::EatInHall,
          Ddt::OrderService::Order::Fastfood,
          Ddt::OrderService::Order::Groupon,
          Ddt::OrderService::Order::Payment,
          Ddt::OrderService::Order::Recharge,
          Ddt::OrderService::Order::Reservation,
          Ddt::OrderService::Cart::EatInHall,
          Ddt::OrderService::Cart::Payment,
          Ddt::OrderService::Cart::Fastfood,
          Ddt::OrderService::Cart::Delivery
      ]
    end

  end
end
