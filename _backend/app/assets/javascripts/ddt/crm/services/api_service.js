CrmModules.add_service('api');
var Api = angular.module('crm.services.api', []);
function formDataObject (data) {
  var fd = new FormData();
  angular.forEach(data, function(value_1, key_1) {
    if(typeof value_1 === "object"){
      angular.forEach(value_1, function(value_2, key_2){
        if(typeof value_2 === "object"){
          angular.forEach(value_2, function(value_3, key_3){
            if(typeof value_3 === "object"){
              angular.forEach(value_3, function(value_4, key_4){
                fd.append(key_1+"["+key_2+"]["+key_3+"]["+key_4+"]", value_4);
              })
            }else{
              fd.append(key_1+"["+key_2+"]["+key_3+"]", value_3);
            }
          })
        }else{
          fd.append(key_1+"["+key_2+"]", value_2);
        }
      })
    }else{
      fd.append(key_1, value_1);
    }
  });
  return fd;
}
var api_base_url = "/backend/crm/shops/" + CrmConst.shop_id;
Api.factory('Shop', ['$resource',function($resource){
  return $resource(api_base_url, {},{
          get:  { method: 'get', params: { }, isArray: false }
        });
}]);
Api.factory('RechargeProduct', ['$resource',function($resource){
  return $resource(api_base_url+'/recharge_products/:id/:action', {},{
          query: { method: "get", isArray: true},
          create: { method: "post"},
          update: { method: "put"},
          destroy: { method: "delete"},
          change_position: { method: "put", params: { action: "change_position"}}
        });
}]);
Api.factory('VipInfo', ['$resource',function($resource){
  return $resource(api_base_url+'/vip_infos/:id/:action', {},{
          query: { method: "get", isArray: true},
          create: { method: "post"},
          update: { method: "put"},
          send_coupon: { method: "post", params: { action: "send_coupon" }},
          batch_destroy: { method: "post", params: { action: "batch_destroy" }},
          credits_clear: { method: "post", params: { action: "credits_clear" }},
          recharge_card_wallet: { method: "post", params: { action: "recharge_card_wallet"}},
          exchange_card_wallet: { method: "post", params: { action: "exchange_card_wallet"}},
          recharge_credits_wallet: { method: "post", params: { action: "recharge_credits_wallet"}},
          agree_apply_vip: { method: "put", params: { action: "agree_apply_vip"}},
          reject_apply_vip: { method: "put", params: { action: "reject_apply_vip"}},
          batch_agree_apply_vip: { method: "post", params: { action: "batch_agree_apply_vip" }},
          block: { method: "put", params: { action: "block"}}
        });
}]);
Api.factory('VipInfoSetting', ['$resource',function($resource){
  return $resource(api_base_url+'/vip_info_setting/:id/:action', {},{
          get: { method: "get"},
          update: { method: "put"}
        });
}]);
Api.factory('CouponSetting', ['$resource',function($resource){
  return $resource(api_base_url+'/coupon_setting/:id/:action', {},{
          get: { method: "get"},
          update: { method: "put"}
        });
}]);
Api.factory('VipLevel', ['$resource',function($resource){
  return $resource(api_base_url+'/vip_levels/:id/:action', {},{
          query: { method: "get", isArray: true},
          create: { method: "post"},
          update: { method: "put"},
          destroy: { method: "delete"},
        });
}]);
Api.factory('CouponVersion', ['$resource',function($resource){
  return $resource(api_base_url+'/coupon_versions/:id/:action', {},{
          query: { method: "get", isArray: true},
          create: { method: "post" },
          update: { method: "put" },
          destroy: { method: "delete"},
        });
}]);
Api.factory('Coupon', ['$resource',function($resource){
  return $resource(api_base_url+'/coupons/:id/:action', {},{
          query: { method: "get", isArray: true},
        });
}]);
Api.factory('CouponPhoto', ['$resource',function($resource){
  return $resource(api_base_url+'/coupon_versions/:coupon_version_id/coupon_photos/:id/:action', {},{
          query: { method: "get", isArray: true},
          create: { method: "post" },
          batch_destroy: { method: "post", params: {action: "batch_destroy"}},
        });
}]);
Api.factory('Branch', ['$resource',function($resource){
  return $resource(api_base_url+'/branches/:id/:action', {},{
          query: { method: "get", isArray: true},
        });
}]);
Api.factory('BranchGroup', ['$resource',function($resource){
  return $resource(api_base_url+'/branch_groups/:id/:action', {},{
          query: { method: "get", isArray: true},
        });
}]);
Api.factory('CouponLog', ['$resource',function($resource){
  return $resource(api_base_url+'/vip_infos/:vip_info_id/coupon_logs/:id/:action', {},{
          query: { method: "get", isArray: true},
        });
}]);
Api.factory('CardWalletLog', ['$resource',function($resource){
  return $resource(api_base_url+'/vip_infos/:vip_info_id/card_wallet_logs/:id/:action', {},{
          query: { method: "get", isArray: true},
        });
}]);
Api.factory('CreditsWalletLog', ['$resource',function($resource){
  return $resource(api_base_url+'/vip_infos/:vip_info_id/credits_wallet_logs/:id/:action', {},{
          query: { method: "get", isArray: true},
        });
}]);
Api.factory('OrderLog', ['$resource',function($resource){
  return $resource(api_base_url+'/vip_infos/:vip_info_id/orders', {},{
          query: { method: "get", isArray: true},
        });
}]);
Api.factory('CreditsSetting', ['$resource',function($resource){
  return $resource(api_base_url+'/credits_setting/:action', {},{
          get: { method: "get"},
          update: { method: "put"}
        });
}]);
