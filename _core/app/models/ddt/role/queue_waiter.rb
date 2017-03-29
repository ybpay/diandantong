module Ddt
  class Role
    class QueueWaiter < Role
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
            :queue_setting => base,
            :guest_queue => [:show, :update, :pass, :accept, :cancel, :notify, :create, :requeue],
          }
        }
      end
    end
  end
end
