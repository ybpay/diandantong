module Ddt
  class Role
    class Boss < Role
      include Role::Builtin

      def permission_set
        Permission.hash_all
      end

    end
  end
end