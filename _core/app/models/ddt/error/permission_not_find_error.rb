module Ddt
  module Error
    class PermissionNotFindError < StandardError
      attr_accessor :scope, :target, :action
      def initialize(scope, target, action)
        @scope = scope
        @target = target
        @action = action
        super("权限未定义: #{scope} #{target} #{action}")
      end
    end
  end
end