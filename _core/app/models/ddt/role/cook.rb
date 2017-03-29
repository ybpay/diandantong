module Ddt
  class Role
    class Cook < Role
      include Role::Builtin
    end
  end
end