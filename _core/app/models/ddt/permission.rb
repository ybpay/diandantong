module Ddt
  class Permission
    include ActsAsType
    attr_accessor :scope, :target, :action, :options
    def initialize(scope, target, action, options={})
      @scope = scope
      @target = target
      @action = action
      @options = options
    end

    def method_name
      "permission__#{scope}__#{target}__#{action}"
    end

    def self.hash_all
      base = [:show, :create, :update, :destroy]
      {
        :shop => {
          :account => base,
          :role => base,
          :shop => [:show, :dashboard, :home, :update],
          :branch => [:create, :destroy, :update, :clear_data],
          :branch_group => base,
          :branch_type => base,

          :printer_code => base,

          :wechat_account => [:manage],
          :wechat_config => [:show, :update],
          :qrcode => base,
          :sign_record => [:show],
          :supply => [:show],

          :call_setting => [:show, :update],
          :credits_setting => [:show, :update],
          :ddb_module => [:show, :update],
          :email_setting => [:show, :update],
          :short_message_setting => [:show, :update],
          :custom_setting => [:show, :update],
          :zone => base,
          :exchange_code => [:show, :exchange],
          :gift_reason => base,
          :subtract_reason => base,
          :merchant_apply => [:manage],
          :recharge_product => base,
          :recharge_refund => [:show, :complete, :cancel],
          :pay_method => base,
          :payment_log => [:show],
          :payment_method => [:show, :update],
          :payment => [:show],
          :event_promotion => base,
          :order_promotion => base,

          :statistic => [:statistics_cache, :business_statistic, :coupon_statistic, :orders_statistic, :product_statistic, :table_statistic, :user_statistic, :worker_statistic, :finance_statistic],
          :user => [:show, :update, :recharge_card_wallet, :exchange_card_wallet, :exchange_credits_wallet, :get_credits_wallet, :send_coupon, :create, :destroy],
          :vip_level => base,
          :card_wallet => [:manage],
          :credits_wallet => [:manage],
          :collection_wallet => [:show, :withdraw],

          :coupon_version => base + [:send_coupon],
          :groupon_version => base,
          :voucher_version => base,
          :coupon => [:show, :apply, :exchange],
          :groupon => [:show, :exchange],
          :voucher => [:show, :exchange],
          :recharge_order => [:show, :create, :reprint, :settle, :cancel],
          :groupon_order => [:show, :confirm, :complete, :cancel, :reprint, :settle, :append_pay_item],
          :feature_modules_config => [:show, :update],
        },
        :branch => {
          :arranging_setting => [:show, :update],
          :cs_branch_binding => [:show, :update],
          :delivery_setting => [:show, :update],
          :eat_in_hall_setting => [:show, :update],
          :reservation_setting => [:show, :update],
          :form_element => base,

          :event_promotion => base,
          :order_promotion => base,
          :discount_plan => base,
          :pay_method => [:show, :update],

          :printer => base,
          :print_record => [:show],
          :print_setting => [:show, :update],
          :bill_template_setting => [:show, :update],

          :queue_setting => base,
          :guest_queue => [:show, :update, :pass, :accept, :cancel, :notify, :create, :requeue],

          :comment => [:show, :reply, :update],
          :tag => [:show, :update, :destroy],
          :waiter_service_item => base,
          :cook => [:manage],

          :essential_product => base,
          :item_note => base,
          :category => base,
          :combo => base,
          :option_type => base,
          :product => [:show, :create, :update, :destroy, :estimate_clear],
          :variant_image => base,
          :combo_image => base,
          :tick_account => base,

          :branch => [:open_shift, :close_shift],
          :shift => [:show],
          :table_zone => base,
          :table => base + [:open, :bind_table, :clear, :check_out, :cancel_check_out, :update_guest_num, :check_out, :force_clear],
          :bill_center => [:discount_list, :waiter_list, :gift_item_list, :subtract_item_list, :sale_list, :payment_list, :shift_list, :combo_package_list, :order_cancel_list, :anti_settlement_list, :queue_list, :by_weight_product_list],
          :order =>
            [
             :show,
             :confirm,
             :complete,
             :cancel,
             :reprint,
             :settle,
             :anti_settlement,
             :append_pay_item,
             :append,
             :gift_item,
             :subtract,
             :hasten,
             :change_vip_info,
             :privilege_discount,
             :cancel_privilege_discount,
             :change_item_price,
             :batch_change_state,
             :add_discount_plan,
             :cancel_discount_plan,
             :add_disabled_promotion,
             :remove_disabled_promotion,
             :refund
            ],
          :delivery_order => [:assign_delivery_man, :start_shipment, :finish_shipment, :create],
          :eat_in_hall_order => [:create, :change_table, :merge_table, :move_itemable, :bind_reservation_order, :trace_waiter, :allow_selfpay, :update_guest_num, :change_line_item_weight],
          :fastfood_order => [:create, :call_customer, :create_and_pay],
          :reservation_order => [:create, :change_to_eat_in_hall, :bind_table, :edit_reservation_info],
          :payment_order => [:create],
          :recharge_order => [:show, :create, :reprint, :settle, :cancel, :init_refund],
          :groupon_order => [:show, :confirm, :complete, :cancel, :reprint, :settle, :append_pay_item],
          :litp => [:show, :confirm_litp, :complete_litp]
        }
      }
    end

    def self.all
      all_group_by_target.map{|_, hash| hash.map{|_, permissions| permissions}}.flatten
    end

    def self.all_group_by_target
      hash_all.map do |scope, hash|
        [
          scope,
          hash.map do |target, actions|
            [target, actions.map{|action| Permission.new(scope, target, action)}]
          end.to_h
        ]
      end.to_h
    end

    def self.scopes
      [:shop, :branch]
    end

    def self.targets
      all.map(&:target).uniq
    end

    def self.actions
      all.map(&:action).uniq
    end

    I18n.locale = :"zh-CN"
    acts_as_type :target, targets, targets.map{|target| I18n.t("permission.targets.#{target}")}
    acts_as_type :action, actions, actions.map{|action| I18n.t("permission.actions.#{action}")}
    acts_as_type :scope,  scopes,  scopes.map{|scope| I18n.t("permission.scopes.#{scope}")}


    def self.is_permission_method?(method_name)
      method_name.to_s =~ /^permission__(.+?)__(.+?)__(.+?)$/
    end

    def text
      "#{target_name}[#{action_name}] #{scope_name}"
    end

    def scope_name
      is_shop? ? "" : Branch.find_by(id: options[:branch_id]).try(:name)
    end
  end
end
