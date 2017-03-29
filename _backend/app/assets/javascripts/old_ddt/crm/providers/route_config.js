CrmModules.add('route_config')
angular.module('crm.route_config',[]).
  provider('RouteConfig',function(){
    this.$get = function(){
      var all_configs = [];

      var base_app_template_url = "/backend/crm/templates/"
      function template(url){
        return base_app_template_url + url + version_timestamp;
      }

      var base_config = [
        {
          state: "home",
          url: '/home',
          templateUrl:  template('home.html'),
          controller:   'HomeController'
        }
      ]

      var vip_setting_config = [
        {
          state: "vip_setting",
          url: "/vip_setting",
          abstract: true,
          templateUrl: template("vip_setting/base.html"),
          controller: "VipSettingController"
        },
        {
          state: "vip_setting.vip_levels",
          url: "/vip_levels",
          views: {
            "main": {
              templateUrl: template("vip_setting/vip_levels.html"),
              controller: "VipSettingVipLevelsController"
            }
          }
        },
        {
          state: "vip_setting.info_setting",
          url: "/info_setting",
          views: {
            "main": {
              templateUrl: template("vip_setting/info_setting.html"),
              controller: "VipSettingInfoSettingController"
            }
          }
        }
      ]

      var user_config = [
        {
          state: "users",
          url: "/users",
          abstract: true,
          templateUrl: template("users/base.html"),
          controller: "UsersController"
        },
        {
          state: "users.index",
          url: "/index",
          views: {
            "main": {
              templateUrl: template("users/index.html"),
              controller: "UsersIndexController"
            }
          }
        }
      ]

      var coupon_setting_config = [
        {
          state: "coupon_setting",
          url: "/coupon_setting",
          abstract: true,
          templateUrl: template("coupon_setting/base.html"),
          controller: "CouponSettingController"
        },
        {
          state: "coupon_setting.coupon_versions",
          url: "/coupon_versions",
          views: {
            "main": {
              templateUrl: template("coupon_setting/coupon_versions.html"),
              controller: "CouponSettingCouponVersionsController"
            }
          }
        },
        {
          state: "coupon_setting.coupons",
          url: "/coupons",
          views: {
            "main": {
              templateUrl: template("coupon_setting/coupons.html"),
              controller: "CouponSettingCouponsController"
            }
          }
        }
      ]

      var other_config = [
        {
          state: "credits_setting",
          url: "/credits_setting",
          templateUrl: template("credits_setting/base.html"),
          controller: "CreditsSettingController"
        },
      ]

      var recharge_config = [
        {
          state: "recharge",
          url: "/recharge",
          abstract: true,
          templateUrl: template("recharge/base.html"),
          controller: "RechargeController"
        },
        {
          state: "recharge.products",
          url: "/products",
          views: {
            "main": {
              templateUrl: template("recharge/products.html"),
              controller: "RechargeProductsController"
            }
          }
        },
        {
          state: "recharge.setting",
          url: "/setting",
          views: {
            "main": {
              templateUrl: template("recharge/setting.html"),
              controller: "RechargeSettingController"
            }
          }
        }
      ]

      add_config(base_config);
      add_config(vip_setting_config);
      add_config(user_config);
      add_config(coupon_setting_config);
      add_config(recharge_config);
      add_config(other_config);

      function get(){
        return all_configs;
      }
      function add_config(config){
        all_configs = all_configs.concat(config);
      }
      return {
        get: get
      }
    }
  });
