module Ddt
  module FeatureCheck
    class << self
      def test
        # 检查feature 是否对不上，或写漏了
        feature_module_all_features = Ddt::FeatureModules.all.map{|v| v[1][:features].to_a}.flatten
        features = Ddt::Features.all.keys

        feature_module_all_features.each do |fa|
          found = false
          features.each do |fb|
            if fa.to_sym == fb.to_sym
              found = true
            end
          end
          if found == false
            puts fa
          end
        end

        puts '-----------------------------------'

        features.each do |fb|
          found = false
          feature_module_all_features.each do |fa|
            if fa.to_sym == fb.to_sym
              found = true
            end
          end
          if found == false
            puts fb
          end
        end

        nil
      end

      def test2
        white_list = [
          # special feature
          :pass,
          :reject,
          # common
          :model_js_error,
          # admin
          :model_app_version,
          :model_joke,
          :model_asset_tag,
          :model_pre_sale_staff,
          :model_sale_employee,
          :model_admin_statistic,
          :model_censor_report,
          :model_withdraw,
          :model_shop_recharge_record,
          :model_sales_email,
          :model_agent,
          :model_agent_rel,
          :model_agent_zone,
          :model_lisence,
          :model_agent_material,
          :model_service_product,
          :model_service_product_order,
          # test help
          :model_test_console,
        ]
        features = Ddt::Features.all.keys
        relobj = Ddt::ActionFeatureRel
        rel_features = []
        [relobj.common_api, relobj.backend, relobj.webpos, relobj.weixin].each do |rel_set|
          rel_set.each do |_k, _v|
            _v.each do |k, v|
              if v.is_a? Proc
                rel_features << v.call({terminal_id: 'app_abc'})
                rel_features << v.call({terminal_id: 'pad_abc'})
              else
                rel_features << v
              end
            end

          end
        end
        rel_features.flatten.each do |fa|
          found = false
          features.each do |fb|
            if fa.to_sym == fb.to_sym
              found = true
            end
          end
          if !found && white_list.exclude?(fa.to_sym)
            puts fa
          end
        end
        nil
      end


    end
  end
end
