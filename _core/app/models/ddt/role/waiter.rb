module Ddt
  class Role
    class Waiter < Role
      include Role::Builtin
      def permission_set
        base = [:show, :create, :update, :destroy]
        {
          :shop => {
            :account => [:show],
            :role => [:show],
            :shop => [:show, :dashboard, :home],
          },
          :branch => {
            :queue_setting => [:show],
            :guest_queue => [:show],
            :category => [:show],
            :combo => [:show],
            :product => [:show, :estimate_clear],
            :table_zone => [:show],
            :table => [:show, :open, :bind_table, :clear, :check_out, :cancel_check_out, :update_guest_num, :check_out],
            :printer => [:show, :index, :reprint, :test_print],
            :order =>
              [
               :show,
               :confirm,
               :reprint,
               :append,
               :hasten,
              ],
            :delivery_order => [:create],
            :eat_in_hall_order => [:create, :change_table, :merge_table, :bind_reservation_order, :trace_waiter, :allow_selfpay, :update_guest_num],
            :fastfood_order => [:create, :call_customer, :create_and_pay],
            :reservation_order => [:create, :change_to_eat_in_hall, :bind_table, :edit_reservation_info],
            :payment_order => [:create],
          }
        }
      end
    end
  end
end
