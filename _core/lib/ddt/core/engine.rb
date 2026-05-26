module Ddt
  module Core
    class Engine < ::Rails::Engine
      isolate_namespace Ddt
      engine_name 'ddt'

      config.i18n.load_path += Dir[config.root.join('config', 'locales', '*.{rb,yml}').to_s]
      config.eager_load_paths += %W(#{config.root}/lib/ddt/core/validators)
      config.eager_load_paths += %W(#{config.root}/app/workers/)
      [
        :search,
        :adjustments,
        :agentsys,
        :assets,
        :coupons,
        :deliveries,
        :ddb_modules,
        :products,
        :tags,
        :statistic,
        :orders,
        :old_orders,
        :users,
        :promotions,
        :notifications,
        :payment,
        :payment2,
        :message,
        :qrcode,
        :custom_info,
        :js_errors,
        :form_element,
        :wallets,
        :pay_method_settings,
        :queue,
        :tables,
        :config,
        :service_products,
        :bill,
        :reservation,
        :shake_around,
        :features,
        :ddb_cs
      ].each do |dir|
        config.eager_load_paths += %W(#{config.root}/app/models/ddt/#{dir})
      end


      initializer "ddt.environment", :before => :load_config_initializers do |app|
        app.config.ddt = Ddt::Core::Environment.new
      end

      initializer 'ddt.promo.environment' do |app|
        app.config.ddt.shop.add_class("event_promotions")
        app.config.ddt.shop.add_class("order_promotions")
        app.config.ddt.branch.add_class("order_promotions")
        app.config.ddt.branch.add_class("event_promotions")
        app.config.ddt.shop.event_promotions     = Ddt::Promo::Environment.new
        app.config.ddt.shop.order_promotions     = Ddt::Promo::Environment.new
        app.config.ddt.branch.event_promotions     = Ddt::Promo::Environment.new
        app.config.ddt.branch.order_promotions     = Ddt::Promo::Environment.new
      end

      initializer 'ddt.promo.register.promotion.calculators' do |app|
        app.config.ddt.shop.calculators.add_class('promotion_actions_order_create_adjustment')
        app.config.ddt.branch.calculators.add_class('promotion_actions_order_create_adjustment')
        app.config.ddt.shop.calculators.promotion_actions_order_create_adjustment = [
          Ddt::Calculator::Order::FlatPercent,
          Ddt::Calculator::Order::FlatRate,
          Ddt::Calculator::Order::FlatReduce,
          Ddt::Calculator::Order::TieredFlatRate,
          Ddt::Calculator::Order::TieredPercent,
          Ddt::Calculator::Order::TieredReduce,
        ]
        app.config.ddt.branch.calculators.promotion_actions_order_create_adjustment = [
          Ddt::Calculator::Order::FlatPercent,
          Ddt::Calculator::Order::FlatRate,
          Ddt::Calculator::Order::FlatReduce,
          Ddt::Calculator::Order::TieredFlatRate,
          Ddt::Calculator::Order::TieredPercent,
          Ddt::Calculator::Order::TieredReduce,
        ]
      end

      initializer 'ddt.promo.register.promotions.rules' do |app|
        app.config.ddt.shop.order_promotions.rules = [
          Ddt::Promotion::Rules::Order::FirstOrderInShop,
          Ddt::Promotion::Rules::Order::ItemTotal,
          Ddt::Promotion::Rules::Order::OneUsePerUser,
          Ddt::Promotion::Rules::Order::PayMethod,
          Ddt::Promotion::Rules::Order::VipOnly,
          Ddt::Promotion::Rules::Order::Variant,
          Ddt::Promotion::Rules::Order::Combo,
        ]
        app.config.ddt.branch.order_promotions.rules = [
          Ddt::Promotion::Rules::Order::Combo,
          Ddt::Promotion::Rules::Order::FirstOrderInBranch,
          Ddt::Promotion::Rules::Order::ItemTotal,
          Ddt::Promotion::Rules::Order::OneUsePerUser,
          Ddt::Promotion::Rules::Order::Variant,
          Ddt::Promotion::Rules::Order::OrderInTimeRange,
          Ddt::Promotion::Rules::Order::PayMethod,
          Ddt::Promotion::Rules::Order::VipOnly,
        ]
        app.config.ddt.shop.event_promotions.rules = [
          Ddt::Promotion::Rules::Event::FirstFollow,
          Ddt::Promotion::Rules::Event::FirstOrderInShop,
          Ddt::Promotion::Rules::Event::FirstOrderTodayInShop,
          Ddt::Promotion::Rules::Event::ItemTotal,
          Ddt::Promotion::Rules::Event::UserContinuousSignCount,
          Ddt::Promotion::Rules::Event::UserSignIn,
          Ddt::Promotion::Rules::Event::UserSignRecordsCount,
          Ddt::Promotion::Rules::Event::UserActiveVip,
          Ddt::Promotion::Rules::Event::VipBirthday,
          Ddt::Promotion::Rules::Event::VipRecharge,
          Ddt::Promotion::Rules::Event::TimesLimit,
          Ddt::Promotion::Rules::Event::ShareToFriendCircle,
          Ddt::Promotion::Rules::Event::VipOnly,
          Ddt::Promotion::Rules::Event::UserTotalAmount,
          Ddt::Promotion::Rules::Event::FromSharedUserRecharge,
        ]
        app.config.ddt.branch.event_promotions.rules = [
          Ddt::Promotion::Rules::Event::FirstOrderInBranch,
          Ddt::Promotion::Rules::Event::FirstOrderTodayInBranch,
          Ddt::Promotion::Rules::Event::ItemTotal,
        ]
      end

      initializer 'ddt.promo.register.promotions.actions' do |app|
        app.config.ddt.shop.order_promotions.actions = [
          Ddt::Promotion::Actions::Order::CreateAdjustment,
          Ddt::Promotion::Actions::Order::FreeShipping,
        ]
        app.config.ddt.branch.order_promotions.actions = [
          Ddt::Promotion::Actions::Order::CreateAdjustment,
          Ddt::Promotion::Actions::Order::FreeShipping,
          Ddt::Promotion::Actions::Order::CategoryDiscount,
          Ddt::Promotion::Actions::Order::ItemDiscount,
          Ddt::Promotion::Actions::Order::ItemReduce,
          Ddt::Promotion::Actions::Order::ItemSecondHalfOff,
        ]
        app.config.ddt.shop.event_promotions.actions = [
          Ddt::Promotion::Actions::Event::GetCoupon,
          Ddt::Promotion::Actions::Event::GetVoucher,
          # Ddt::Promotion::Actions::Event::GetSharableCoupon,
          Ddt::Promotion::Actions::Event::GetCredits,
          Ddt::Promotion::Actions::Event::GetCreditsPercent,
        ]
        app.config.ddt.branch.event_promotions.actions = [
          Ddt::Promotion::Actions::Event::GetCredits,
          Ddt::Promotion::Actions::Event::GetCreditsPercent,
        ]
      end

      # filter sensitive information during logging
      initializer "ddt.params.filter" do |app|
        app.config.filter_parameters += [
            :password,
          :password_confirmation,
          :pay_password]
      end


      initializer :append_migrations do |app|
        unless app.root.to_s.match root.to_s
          config.paths["db/migrate"].expanded.each do |expanded_path|
            app.config.paths["db/migrate"] << expanded_path
          end
        end
      end
    end
  end
end
