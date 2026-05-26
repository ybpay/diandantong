module Ddt
  class VipInfoSetting < Ddt::Base

    include BelongsToShop
    serialize :data, Hash

    def self.hash_data_config(data_column, configs)
      configs.each do |name, config|
        case config[:type]
        when :string
          define_method name do
            self.send(data_column).fetch(name, config[:default]).try(:to_s)
          end
          define_method "#{name}=" do |value|
            self.send(data_column)[name] = value
          end
        when :int
          define_method name do
            self.send(data_column).fetch(name, config[:default]).try(:to_i)
          end
          define_method "#{name}=" do |value|
            self.send(data_column)[name] = value.try(:to_i)
          end
        when :boolean
          define_method name do
            !!self.send(data_column).fetch(name, config[:default])
          end
          define_method "#{name}=" do |value|
            self.send(data_column)[name] = ["1", "true", true].include?(value)
          end
        else
        end
      end
      define_singleton_method :config_columns do
        configs.keys
      end
    end

    hash_data_config :data, {
      name_display:  { type: :boolean, default: true },
      phone_display: { type: :boolean, default: true },
      sex_display:   { type: :boolean, default: false },
      birthday_display: { type: :boolean, default: false },
      address_display: { type: :boolean, default: false },
      email_display: { type: :boolean, default: false },
      name_required:  { type: :boolean, default: true },
      phone_required: { type: :boolean, default: true },
      sex_required:   { type: :boolean, default: false },
      birthday_required: { type: :boolean, default: false },
      address_required: { type: :boolean, default: false },
      email_required: { type: :boolean, default: false },
      default_password: { type: :string, default: "123456"},
      show_rechange_module: { type: :boolean, default: true },
      show_vippay_module: { type: :boolean, default: true },
      show_order_module: { type: :boolean, default: true },
      show_coupon_module: { type: :boolean, default: true },
      show_credits_exchange_module: { type: :boolean, default: true },
      show_sign_record_module: { type: :boolean, default: true },
      show_share_record_module: { type: :boolean, default: true },
      show_address_module: { type: :boolean, default: true },
      show_collect_module: { type: :boolean, default: true },
      auto_agree_applying: { type: :boolean, default: false },
      enable_blur_search: { type: :boolean, default: true },
      recharge_type: { type: :string, default: "recharge_product" }, # recharge_product temp_recharge_product
      can_change_vip_level_in_webpos: { type: :boolean, default: false },
      disable_recharge_when_query: { type: :boolean, default: false },
      allow_credits_exchange_and_get: { type: :boolean, default: false },
      enable_query_for_settle: { type: :boolean, default: true },
    }

    def as_json
      json = {}
      self.class.config_columns.each do |column|
        json[column] = self.send(column)
      end
      json
    end
  end
end
