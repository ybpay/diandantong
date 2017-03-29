module Ddt
  module FeatureModuleGroup

    class << self

      # def base
      #   {
      #     name: 'webpos',
      #     label: '免费基础收银',
      #     price: 0,
      #     charge_by_year: false, #是否按年付费
      #     charge_by_branch: false, #是否按门店计费
      #     modules: [
      #       :base, :eat_in_hall, :delivery, :reservation, :payment, :fastfood
      #     ]
      #   }
      # end

      def all
        [
          :base, :webpos, :wechat_eat_in_hall, :wechat_delivery,
          :wechat_reservation, :wechat_fastfood, :crm, :payment,
          :wms, :k1, :k1_p, :k2, :k2_p, :k3, :k3_p, :k4, :k5, :z1, :z1_p, :z2, :z2_p, :z3, :z3_p, :z4, :z5,
          :o1, :o2, :o3, :oem, :sdu]
      end

      def all_values
        self.all.map{|k| self.send(k)}
      end

      def all_values_without_base
        self.all.select{|m| m != :base}.map{|k| self.send(k)}
      end

      def base
        {
          name: 'base',
          label: '免费基础收银',
          icon: 'fa-cogs',
          price: 0,
          charge_by_branch: 1,
          modules: [
            :base, :eat_in_hall, :delivery, :reservation, :payment, :fastfood
          ].flatten.uniq
        }
      end


      def webpos
        {
          name: 'webpos',
          label: '标准点餐收银',
          icon: 'fa-th',
          price: 1500,
          charge_by_branch: 1,
          modules: [
            self.base[:modules], :pay_base
          ].flatten.uniq
        }
      end


      def wechat_eat_in_hall
        {
          name: 'wechat_eat_in_hall',
          label: "微信扫码堂点",
          icon: 'fa-wechat',
          price: 2480,
          charge_by_branch: 1,
          modules: [
            self.webpos[:modules], :wechat_base, :eat_in_hall_on_wechat
          ].flatten.uniq
        }
      end

      def wechat_delivery
        {
          name: 'wechat_delivery',
          label: '微信外卖',
          icon: 'fa-motorcycle',
          price: 2480,
          charge_by_branch: 1,
          modules: [
            self.webpos[:modules], :wechat_base, :delivery_on_wechat
          ].flatten.uniq
        }
      end

      def wechat_reservation
        {
          name: 'wechat_reservation',
          label: '微信预定',
          icon: 'fa-pencil-square-o',
          price: 2480,
          charge_by_branch: 1,
          modules: [
            self.webpos[:modules], :wechat_base, :reservation_on_wechat,
          ].flatten.uniq
        }
      end

      def wechat_fastfood
        {
          name: 'wechat_fastfood',
          label: '微信快餐',
          icon: 'fa-cutlery',
          price: 2480,
          charge_by_branch: 1,
          modules: [
            self.webpos[:modules], :wechat_base, :fastfood_on_wechat
          ].flatten.uniq
        }
      end

      def crm
        {
          name: 'crm',
          label: '微信会员',
          icon: 'fa-credit-card',
          price: 2480,
          charge_by_branch: 1,
          modules: [
            self.webpos[:modules], :wechat_base, :vip, :event_promotion, :coupon
          ].flatten.uniq
        }
      end

      def payment
        {
          name: 'payment',
          label: '买单',
          icon: 'fa-credit-card',
          price: 2480,
          charge_by_branch: 1,
          modules: [
            self.webpos[:modules], :wechat_base, :payment, :payment_on_wechat
          ].flatten.uniq
        }
      end


      def wms
        {
          name: 'wms',
          label: '供应链系统',
          icon: 'fa-truck',
          price: 1500,
          charge_by_branch: 1,
          modules: [
            :base, :wms
          ].flatten.uniq
        }
      end

      def k1
        {
          name: 'k1',
          label: '快餐基础解决方案',
          icon: 'fa-pencil-square-o',
          price: 2880,
          charge_by_branch: 1,
          modules: [
            self.wechat_fastfood[:modules], self.wechat_delivery[:modules]
          ].flatten.uniq
        }
      end

      def k2
        {
          name: 'k2',
          label: '快餐标准解决方案',
          icon: 'fa-pencil-square-o',
          price: 3880,
          charge_by_branch: 1,
          modules: [
            self.wechat_fastfood[:modules], self.wechat_delivery[:modules], self.crm[:modules], :event_promotion, :coupon, :groupon
          ].flatten.uniq
        }
      end

      def k3
        {
          name: 'k3',
          label: '快餐豪华解决方案',
          icon: 'fa-pencil-square-o',
          price: 4980,
          charge_by_branch: 1,
          modules: [
            self.wechat_fastfood[:modules], self.wechat_delivery[:modules], self.crm[:modules], :event_promotion, :coupon, :groupon, :app, :queue,
          ].flatten.uniq
        }
      end

      def k1_p
        {
          name: 'k1_p',
          label: '快餐基础解决方案+打印',
          icon: 'fa-pencil-square-o',
          price: 3380,
          charge_by_branch: 1,
          modules: [
            self.k1[:modules], :bill_template
          ].flatten.uniq
        }
      end

      def k2_p
        {
          name: 'k2_p',
          label: '快餐标准解决方案+打印',
          icon: 'fa-pencil-square-o',
          price: 4380,
          charge_by_branch: 1,
          modules: [
            self.k2[:modules], :bill_template
          ].flatten.uniq
        }
      end

      def k3_p
        {
          name: 'k3_p',
          label: '快餐豪华解决方案+打印',
          icon: 'fa-pencil-square-o',
          price: 5480,
          charge_by_branch: 1,
          modules: [
            self.k3[:modules], :bill_template
          ].flatten.uniq
        }
      end

      def k4
        {
          name: 'k4',
          label: '快餐旗舰解决方案',
          icon: 'fa-pencil-square-o',
          price: 5480,
          charge_by_branch: 1,
          modules: [
            self.wechat_fastfood[:modules], self.wechat_delivery[:modules], self.crm[:modules], :event_promotion, :coupon, :groupon, :app, :kitchen, :statistic, :bill_template
          ].flatten.uniq
        }
      end

      def k5
        {
          name: 'k5',
          label: '快餐连锁解决方案',
          icon: 'fa-pencil-square-o',
          price: 7480,
          charge_by_branch: 1,
          modules: [
            self.wechat_fastfood[:modules], self.wechat_delivery[:modules], self.crm[:modules], :event_promotion, :coupon, :groupon, :app, :kitchen, :statistic, :bill_template, :cs, :chain
          ].flatten.uniq
        }

      end

      def z1
        {
          name: 'z1',
          label: '中餐基础解决方案',
          icon: 'fa-pencil-square-o',
          price: 2880,
          charge_by_branch: 1,
          modules: [
            self.wechat_eat_in_hall[:modules], self.wechat_reservation[:modules], self.wechat_delivery[:modules]
          ].flatten.uniq
        }
      end

      def z2
        {
          name: 'z2',
          label: '中餐标准解决方案',
          icon: 'fa-pencil-square-o',
          price: 4580,
          charge_by_branch: 1,
          modules: [
            self.z1[:modules], self.crm[:modules], :event_promotion, :coupon, :groupon
          ].flatten.uniq
        }
      end

      def z3
        {
          name: 'z3',
          label: '中餐豪华解决方案',
          icon: 'fa-pencil-square-o',
          price: 5980,
          charge_by_branch: 1,
          modules: [
            self.z2[:modules], :pad, :app, :queue
          ].flatten.uniq
        }
      end



      def z1_p
        {
          name: 'z1_p',
          label: '中餐基础解决方案+打印',
          icon: 'fa-pencil-square-o',
          price: 3380,
          charge_by_branch: 1,
          modules: [
            self.z1[:modules], :bill_template
          ].flatten.uniq
        }
      end 

      def z2_p
        {
          name: 'z2_p',
          label: '中餐标准解决方案+打印',
          icon: 'fa-pencil-square-o',
          price: 5080,
          charge_by_branch: 1,
          modules: [
            self.z2[:modules], :bill_template
          ].flatten.uniq
        }
      end

      def z3_p
        {
          name: 'z3',
          label: '中餐豪华解决方案+打印',
          icon: 'fa-pencil-square-o',
          price: 6480,
          charge_by_branch: 1,
          modules: [
            self.z3[:modules], :bill_template
          ].flatten.uniq
        }
      end

      def z4
        {
          name: 'z4',
          label: '中餐旗舰解决方案',
          icon: 'fa-pencil-square-o',
          price: 6880,
          charge_by_branch: 1,
          modules: [
            self.z3[:modules], :kitchen, :statistic, :bill_template
          ].flatten.uniq
        }

      end

      def z5
        {
          name: 'z5',
          label: '中餐连锁解决方案',
          icon: 'fa-pencil-square-o',
          price: 8680,
          charge_by_branch: 1,
          modules: [
            self.z4[:modules], :cs, :chain
          ].flatten.uniq
        }
      end

      def o1
        {
          name: 'o1',
          label: '本地生活商圈基础版',
          icon: 'fa-map',
          price: 4880,
          charge_by_branch: 150,
          modules: [
            self.wechat_delivery[:modules], :business_circle, :app
          ].flatten.uniq
        }
      end

      def o2
        {
          name: 'o2',
          label: '本地生活商圈标准版',
          icon: 'fa-map',
          price: 9880,
          charge_by_branch: 150,
          modules: [
            self.o1[:modules], self.wechat_eat_in_hall[:modules], self.wechat_reservation[:modules], :queue, :app
          ].flatten.uniq
        }
      end

      def o3
        {
          name: 'o3',
          label: '本地生活商圈豪华版',
          icon: 'fa-map',
          price: 36000,
          charge_by_branch: 150,
          modules: [
            self.o2[:modules], self.wechat_fastfood[:modules], self.crm[:modules], self.payment[:modules], :pad, :groupon, :coupon, :event_promotion, :bill_template, :statistic
          ].flatten.uniq
        }
      end

      def oem
        {
          name: 'oem',
          label: 'oEM品牌',
          icon: 'fa-chrome',
          price: 20000,
          charge_by_branch: 1,
          charge_by_days: false,
          modules: [
            :base, :oem
          ]
        }
      end

      def sdu
        {
          name: 'sdu',
          label: '物业数据上传',
          icon: 'fa-cloud-upload',
          price: 4000,
          charge_by_branch: 1,
          modules: [
            :base, :sdu
          ]
        }
      end

      def trial
        {
          name: 'trial',
          label: '试用模块',
          icon: 'fa-cloud-upload',
          price: 10000,
          charge_by_branch: 1,
          modules: [
            self.z5[:modules], self.k5[:modules], self.o3[:modules], :base, :sdu, :chain, :cs
          ].flatten.uniq
        }
      end

      def group_of_upgradable(shop, max_branches_limit)
        self.all_values.select{|fmg| self.can_upgrade_to?(shop, max_branches_limit, fmg[:name])}
      end

      def select_json
        self.all.map do |feature_module_group|
          fmg = self.send(feature_module_group)
          {
            id: fmg[:name],
            name: fmg[:label],
          }
        end
      end

      def group_name(feature_module_group_str)
        self.send(feature_module_group_str.to_sym)[:label]
      end

      def module_names(feature_module_group_str)
        modules = self.send(feature_module_group_str.to_sym)[:modules]
        modules.map{|m| Ddt::FeatureModules.feature_modules_name(m)}.join(", ")
      end

      def can_upgrade_to?(shop, max_branches_limit, new_feature_module_group_str)
        old_fmg = self.send(shop.shop_type.to_sym)
        new_feature_module_group = self.send(new_feature_module_group_str.to_sym)
        shop.branches.size <= max_branches_limit &&
          shop.max_branches_limit <= max_branches_limit &&
          old_fmg[:modules].size == (old_fmg[:modules] & new_feature_module_group[:modules]).size
      end

      def price_of_charge_version(shop, ending_time, max_branches_limit, new_feature_module_group_str)
        if shop.branches.size > max_branches_limit
          raise '当前门店数量超过允许的门店数量，需要先删除多余的门店'
        end
        current_time = DateTime.now
        new_amount = amount_of(new_feature_module_group_str, ((ending_time - current_time).to_i/3600/24).to_i, max_branches_limit)
        left_amount = amount_of(shop.shop_type, ((shop.expiration_time - current_time).to_i/3600/24).to_i, shop.max_branches_limit)
        if new_amount < left_amount
          0
        else
          (new_amount - left_amount).round(2)
        end
      end

      def amount_of(feature_module_group_str, days, max_branches_limit)
        feature_module_group = self.send(feature_module_group_str.to_sym)
        amount = (max_branches_limit.to_f/feature_module_group[:charge_by_branch]).ceil * feature_module_group[:price] * (days.to_f/365)
        amount.round(2)
      end

      def version_description(fmg)
        "版本号：#{fmg[:name].upcase}，版本名：#{fmg[:label]}, 价格：#{fmg[:price]}/#{fmg[:charge_by_branch]}店/年\n功能模块：#{module_names(fmg[:name])}"
      end
    end
  end
end
