module Ddt
  class Role < ActiveRecord::Base
    include ActsAsType


    has_and_belongs_to_many :accounts, :join_table => 'ddt_accounts_roles', class_name: 'Ddt::Account'

    belongs_to :resource, polymorphic: true
    belongs_to :shop, class_name: 'Ddt::Shop'
    validates :shop, presence: true, unless: 'name == :admin'
    serialize :permission_set, Hash

    # validates :name, uniqueness: [:scope=> :shop_id], presence: true
    validates :name, presence: true
    validates :display_name, uniqueness: {:scope => [:shop_id]}, presence: true, unless: :builtin?

    acts_as_type :type, [
      "Ddt::Role::Admin",
      "Ddt::Role::Boss",
      "Ddt::Role::Worker",
      "Ddt::Role::Deliveryman",
      "Ddt::Role::Cook",
      "Ddt::Role::Chef",
      "Ddt::Role::Waiter",
      "Ddt::Role::Cashier",
      "Ddt::Role::VipInfoManager",
      "Ddt::Role::QueueWaiter",
      "Ddt::Role::Accountant",
      "Ddt::Role::Custom",
    ], %W[点单通系统管理员 管理员 店长 配送员 厨师 厨师长 服务员 收银员 会员管理者 排号员 财务员 自定义角色]

    scope :custom, ->{ where(type: "Ddt::Role::Custom", name: :custom, builtin: false)}
    scope :builtin, ->{ where(builtin: true)}

    def self.types
      [:admin, :boss, :worker, :deliveryman, :cook, :chef, :waiter, :cashier, :vip_info_manager, :queue_waiter, :accountant, :custom]
    end

    def self.type_str
      self.name.demodulize.underscore
    end

    def type_str
      self.class.type_str
    end

    types.each do |role_type|
      define_method "is_#{role_type}?" do
        self.type_str.to_sym == role_type
      end
      scope "#{role_type}_role", -> {where(type: "Ddt::Role::#{role_type.to_s.camelize}")}
    end


    def self.admin_role
      where(type: "Ddt::Role::Admin", name: :admin, display_name: "点单通系统管理员", builtin: true).first_or_create!
    end

    def builtin_name
      builtin? ? I18n.t("role.builtin.positive") : I18n.t("role.builtin.negative")
    end

    def display_name
      builtin? ? type_name : self.read_attribute(:display_name)
    end

    def permission_description
      I18n.t("role.permission_description.#{name}") if builtin?
    end

    def select_json
      { id: id, name: name, display_name: display_name }
    end

    concerning :PermissionMethod do
      included do
        Permission.all.each do |permission|
          scope = permission.scope
          target = permission.target
          action = permission.action
          method_name = permission.method_name
          define_method method_name do
            actions = self.permission_set.fetch(scope, {}).fetch(target, [])
            actions.include?(permission.action.to_sym)
          end
          define_method "#{method_name}=" do |new_value|
            # [true, 1, '1'] => true
            # [false, 0, '0'] => false
            self.permission_set[scope] ||= {}
            self.permission_set[scope][target] ||= []
            if [true, 1, '1'].include?(new_value)
              self.permission_set[scope][target].push(action.to_sym)
              self.permission_set[scope][target].uniq!
            else
              self.permission_set[scope][target].delete(action.to_sym)
            end
          end
        end

        def self.permission_methods
          self.instance_methods(false).select{|name| Permission.is_permission_method?(name)}
        end

        def permissions_group_by_target
          @permissions_group_by_target ||= self.permission_set.map do |scope, hash|
            [scope, hash.map do |target, actions|
              [target, actions.map{|action| Permission.new(scope, target, action) }]
            end.to_h]
          end.to_h
        end

        def permissions
          @permissions ||= permissions_group_by_target.map{|_, h| h.map{|_, p| p}}.flatten
        end

        def permission_set_text
          permissions_group_by_target.map do |scope, hash|
            I18n.t("permission.scopes.#{scope}") + "\n" +
            hash.map do |target, permissions|
              "#{Permission.target_name(target)}[#{permissions.map(&:action_name).join(',')}]" if permissions.present?
            end.compact.join("\n")
          end.join("\n")
        end

        def can?(scope, target, action)
          permission = Permission.new(scope, target, action)
          self.send(permission.method_name)
        end

        def can(scope, target, action)
          permission = Permission.new(scope, target, action)
          self.send("#{permission.method_name}=", true)
        end

        def cannot(scope, target, action)
          permission = Permission.new(scope, target, action)
          self.send("#{permission.method_name}=", false)
        end

        def method_missing(method_name, *args, &block)
          if method_name.to_s =~ /^permission__(.+?)__(.+?)__(.+?)$/
            raise Error::PermissionNotFindError.new($1, $2, $3)
          else
            super
          end
        end

        def self.merged_permissions(roles)
          permissions = { shop: {}, branch: {} }
          roles.each do |role|
            role.permission_set.each do |scope, hash|
              hash.each do |target, actions|
                permissions[scope][target] ||= []
                permissions[scope][target] += actions
                permissions[scope][target].uniq!
              end
            end
          end
          permissions
        end
      end
    end
  end
end
