# frozen_string_literal: true

module Ddt
  module CheckPermission
    extend ActiveSupport::Concern
    included do
      def self.base_permission_actions
        {
          [:index, :show] => :show,
          [:new, :create] => :create,
          [:edit, :update, :change_position] => :update,
          :destroy => :destroy
        }
      end

      def self.check_permission(scope, target, actions = nil, options = {})
        method_name = "check_permission_#{scope}_#{target}_01"
        while method_defined? method_name
          method_name = method_name.next
        end
        define_method method_name do
          return if options[:except].present? && options[:except].include?(action_name.to_sym)
          return if options[:only].present? && !options[:only].include?(action_name.to_sym)
          permission_action =
            case actions
            when Hash, nil
              actions ||= self.class.base_permission_actions
              actions.detect { |key, value|
                (key.is_a?(Array) && key.include?(action_name.to_sym)) || (key == action_name.to_sym)
              }.try(:[], 1)
            when Symbol, String
              actions.to_sym
            end
          permission_action = action_name.to_sym if permission_action.blank?

          begin
            policy_class = "Ddt::#{target.to_s.camelize}Policy".constantize
            policy = policy_class.new(
              nil,
              account: current_account,
              shop: current_shop,
              branch: current_branch
            )
            result = policy.apply("#{permission_action}?".to_sym)
            unless result
              raise Error::NoPermissionError.new(
                Permission.new(scope, target, permission_action, branch_id: current_branch&.id)
              )
            end
          rescue NameError
            # Fallback to Account#authorize! if no policy class exists
            case scope
            when :shop
              authorize!(scope, target, permission_action)
            when :branch
              authorize!(scope, target, permission_action, branch_id: params[:branch_id])
            end
          end
        end
        before_action method_name
      end
    end
  end
end
