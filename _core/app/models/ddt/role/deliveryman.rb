module Ddt
  class Role
    class Deliveryman < Role
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
            :order => [:show, :hasten],
            :delivery_order => [:assign_delivery_man, :start_shipment, :finish_shipment],
          }
        }
      end
    end
  end
end
