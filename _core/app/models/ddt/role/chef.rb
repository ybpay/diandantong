module Ddt
  class Role
    class Chef < Role
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
            :litp => [:show, :confirm_litp, :complete_litp],
          }
        }
      end
    end
  end
end
