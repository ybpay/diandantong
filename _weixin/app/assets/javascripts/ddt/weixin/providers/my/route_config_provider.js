angular.module('ddt_app.route_config.my', []).
  provider('RouteConfig', function () {
    this.$get = function(){
        var all_configs = []
        var base_configs = [
           {
            path:         '/',
            templateUrl:  '/my/shop/my.html',
            controller:   'myController',
            feature:      'model_user'
          },
          {
            path:         '/user/profile',
            templateUrl:  '/my/shop/my.html',
            controller:   'myController',
            feature:      'model_user'
          }
        ]

        var user_configs = [
          {
            path:         '/user/scan-code',
            templateUrl:  '/my/user/scan-code.html',
            controller:   'userScanCodeController',
            feature:      'model_vip_info'
          },
          {
            path:         '/user/update-vip-info',
            templateUrl:  '/my/user/update-vip-info.html',
            controller:   'updateVipInfoController',
            feature:      'model_vip_info'
          },
          {
            path:         '/user/update-pay-password',
            templateUrl:  '/my/user/update-pay-password.html',
            controller:   'userUpdatePayPasswordController',
            feature:      'model_vip_info'
          },
          {
            path:         '/user/bind-vip',
            templateUrl:  '/my/user/bind-vip.html',
            controller:   'userBindVipController',
            feature:      'model_vip_info'
          },
          {
            path:         '/user/vip-info-detail',
            templateUrl:  '/my/user/vip-info-detail.html',
            controller:   'userVipInfoDetailController',
            feature:      'model_vip_info'
          },
          {
            path:         '/user/card-wallet-log',
            templateUrl:  '/my/user/card-wallet-log.html',
            controller:   'userCardWalletLogController',
            feature:      'model_vip_info'
          },
          {
            path:         '/user/settings',
            templateUrl:  '/my/user/settings.html',
            controller:   'settingsController',
            feature:      'model_user'
          }


        ]

        var coupon_configs = [
          {
            path:           '/user/coupon_nav',
            templateUrl:    '/my/coupon/nav.html',
            controller:     'couponNavController',
            feature:        'base_promotion'
          },
          {
            path:         '/user/exchange/nav',
            templateUrl:  '/my/coupon/exchange/nav.html',
            controller:   'exchangeNavController',
            feature:      'base_promotion',
          },
          {
            path:         '/user/exchange/coupon_versions/:id/',
            templateUrl:  '/my/coupon/exchange/coupon_version.html',
            controller:   'CouponVersionController',
            feature:      'base_promotion',
          },
          {
            path:         '/user/exchange/coupon_versions/:id/exchange',
            templateUrl:  '/my/coupon/exchange/exchange.html',
            controller:   'CouponVersionController',
            feature:      'base_promotion',
          },
          {
            path:         '/user/exchange/success',
            templateUrl:  '/success.html',
            controller:   'exchangeSuccess',
            feature:      'base_promotion',
          },
          {
            path:         '/user/credits',
            templateUrl:  '/my/coupon/credits.html',
            controller:   'creditsController',
            feature:      'base_promotion',
          },
          {
            path:         '/user/coupons',
            templateUrl:  '/my/coupon/coupons.html',
            controller:   'couponsController',
            feature:      'base_promotion',
          },
          {
            path:         '/user/coupons/:base_coupon_id',
            templateUrl:  '/my/coupon/coupon.html',
            controller:   'couponController',
            feature:      'base_promotion',
          },
          {
            path:         '/user/groupons',
            templateUrl:  '/my/coupon/groupons.html',
            controller:   'grouponsController',
            feature:      'base_groupon',
          },
          {
            path:         '/user/groupons/:base_coupon_id',
            templateUrl:  '/my/coupon/groupon.html',
            controller:   'grouponController',
            feature:      'base_groupon',
          },
          {
            path:         '/user/vouchers',
            templateUrl:  '/my/coupon/vouchers.html',
            controller:   'vouchersController',
            feature:      'base_groupon',
          },
          {
            path:         '/user/vouchers/:base_coupon_id',
            templateUrl:  '/my/coupon/voucher.html',
            controller:   'voucherController',
            feature:      'base_groupon',
          },
          {
            path:         '/user/sharable_coupons',
            templateUrl:  '/my/coupon/sharable_coupons.html',
            controller:   'sharableCouponsController',
            feature:      'no_used_any_more'
          },
          {
            path:         '/user/sharable_coupons/:sharable_coupon_id',
            templateUrl:  '/my/coupon/sharable_coupon.html',
            controller:   'sharableCouponController',
            feature:      'no_used_any_more'
          },
          {
            path:         '/user/sharable_coupons/:sharable_coupon_id/received',
            templateUrl:  '/my/coupon/sharable_coupon_received.html',
            controller:   'sharableCouponController',
            feature:      'no_used_any_more'
          },
          {
            path:         '/sharable_coupons/:sharable_coupon_id',
            templateUrl:  '/my/sharing_coupon.html',
            controller:   'sharingCouponController',
            feature:      'no_used_any_more'
          }
        ]

        var exchange_code_configs = [
          {
            path:         '/exchange_codes/:exchange_code_id',
            templateUrl:  '/exchange_codes/show.html',
            controller:   'exchangeCodeController',
            feature:      'wechat_api'
          }
        ]

        var sign_record_configs = [
          {
            path:         '/sign_records',
            templateUrl:  '/my/sign_records.html',
            controller:   'signRecordsController',
            feature:      'wechat_api'
          }
        ]

        var wechat_share_record_configs = [
          {
            path:         '/wechat_share_records',
            templateUrl:  '/my/wechat_share_records/index.html',
            controller:   'wechatShareRecordsController',
            feature:      'wechat_api'
          },
          {
            path:         '/wechat_share_records/:wechat_share_record_id',
            templateUrl:  '/my/wechat_share_records/show.html',
            controller:   'wechatShareRecordController',
            feature:      'wechat_api'
          }
        ]


        var exchange_code_configs = [
          {
            path:         '/exchange_codes/:exchange_code_id',
            templateUrl:  '/my/exchange_codes/show.html',
            controller:   'exchangeCodeController',
            feature:      'wechat_api'
          }
        ]


        add_config(base_configs);
        add_config(user_configs);
        add_config(coupon_configs);
        add_config(exchange_code_configs);
        add_config(sign_record_configs);
        add_config(wechat_share_record_configs);
        add_config(exchange_code_configs);

        function get(){
          return all_configs;
        }

        function add_config(config){
          all_configs = all_configs.concat(config)
        }

        return {
            get: get
        }
    }
  })
