module Ddt
  class Role
    class Worker < Role
      include Role::Builtin

      def permission_set
        base = [:show, :create, :update, :destroy]
        {
          :shop => {
            :account => [:show],
            :role => [:show],
            :shop => [:show, :dashboard, :home],
            :branch => [:update],
            :branch_group => [:show],
            :branch_type => [:show],

            :qrcode => [:show],
            :supply => [:show],

            :exchange_code => [:show, :exchange],
            :payment_log => [:show],
            :payment => [:show],
            :event_promotion => [:show],
            :order_promotion => [:show],

            :statistic => [:business_statistic, :coupon_statistic, :orders_statistic, :product_statistic, :table_statistic, :user_statistic, :worker_statistic],
            :user => [:show, :update, :recharge_card_wallet, :exchange_card_wallet, :exchange_credits_wallet, :get_credits_wallet, :send_coupon, :create, :destroy],
            :coupon => [:show, :apply, :exchange],
            :groupon => [:show, :exchange],
            :voucher => [:show, :exchange]
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
               :confirm_line_item_trace_point,
               :cancel_line_item_trace_point,
               :add_discount_plan,
               :cancel_discount_plan,
               :add_disabled_promotion,
               :remove_disabled_promotion,
               :refund
              ],
            :delivery_order => [:assign_delivery_man, :start_shipment, :finish_shipment, :create],
            :eat_in_hall_order => [:create, :change_table, :merge_table, :bind_reservation_order, :trace_waiter, :allow_selfpay, :update_guest_num, :change_line_item_weight],
            :fastfood_order => [:create, :call_customer, :create_and_pay],
            :reservation_order => [:create, :change_to_eat_in_hall, :bind_table, :edit_reservation_info],
            :payment_order => [:create],
            :recharge_order => [:show, :create, :reprint, :settle, :cancel],
          }
        }
      end
    end
  end
end
