module Ddt
  class Role
    class Accountant < Role
      include Role::Builtin
      def permission_set
        base = [:show, :create, :update, :destroy]
        {
          :shop => {
            :account => [:show],
            :role => [:show],
            :shop => [:show, :dashboard, :home],
            :statistic => [:business_statistic, :coupon_statistic, :orders_statistic, :product_statistic, :table_statistic, :user_statistic, :worker_statistic],
          },
          :branch => {
            :bill_center => [:discount_list, :waiter_list, :gift_item_list, :subtract_item_list, :sale_list, :payment_list, :shift_list, :combo_package_list, :order_cancel_list, :anti_settlement_list, :queue_list, :by_weight_product_list],
          }
        }
      end
    end
  end
end
