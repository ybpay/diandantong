module Ddt
  module Error
    class NoPermissionError < StandardError
      attr_accessor :permission
      def initialize(permission)
        @permission = permission
        super("没有权限 #{permission.text}")
      end
    end
  end
end