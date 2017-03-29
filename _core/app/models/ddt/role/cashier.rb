module Ddt
  class Role
    class Cashier < Role
      include Role::Builtin
      def permission_set
        base = [:show, :create, :update, :destroy]
        {
          :shop => {
            :account => [:show],
            :role => [:show],
            :shop => [:show, :dashboard, :home],
            :exchange_code => [:show, :exchange],
            :payment_log => [:show],
            :payment => [:show],
            :user => [:show, :update, :recharge_card_wallet, :exchange_card_wallet, :exchange_credits_wallet, :get_credits_wallet],
            :coupon => [:show, :apply, :exchange],
            :groupon => [:show, :exchange],
            :voucher => [:show, :exchange]
          },
          :branch => {
            :queue_setting => base,
            :guest_queue => [:show, :update, :pass, :accept, :cancel, :notify, :create, :requeue],
            :product => [:show, :estimate_clear],
            :branch => [:open_shift, :close_shift],
            :shift => [:show],
            :table => [:show, :open, :bind_table, :clear, :check_out, :cancel_check_out, :update_guest_num, :check_out, :force_clear],
            :bill_center => [:discount_list, :waiter_list, :gift_item_list, :subtract_item_list, :sale_list, :payment_list, :shift_list, :combo_package_list, :order_cancel_list, :anti_settlement_list, :queue_list, :by_weight_product_list],
            :order =>
              [
               :show,
               :confirm,
               :complete,
               :reprint,
               :settle,
               :hasten,
               :change_vip_info,
               :cancel_privilege_discount,
               :change_item_price,
               :batch_change_state,
               :cancel_discount_plan,
               :add_disabled_promotion,
               :remove_disabled_promotion
              ],
            :delivery_order => [:create],
            :eat_in_hall_order => [:create, :change_table, :merge_table, :bind_reservation_order, :trace_waiter, :allow_selfpay, :update_guest_num, :change_line_item_weight],
            :fastfood_order => [:create, :call_customer, :create_and_pay],
            :reservation_order => [:create, :change_to_eat_in_hall, :bind_table, :edit_reservation_info],
            :payment_order => [:create],
          }
        }
      end
    end
  end
end
