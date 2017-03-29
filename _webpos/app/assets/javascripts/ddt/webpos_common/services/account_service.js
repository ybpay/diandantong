WebposModules.add_service('account')
angular.module('webpos.services.account', []).
  factory('AccountService', ['$rootScope', '$resource', '$http', 'PermissionService','NotifyService',
    function($rootScope, $resource, $http, PermissionService, NotifyService){
      var Accounts = $resource('/webpos/webpos_accounts/:action', {},{
        sign_in:  { method: 'post',   params: { action: 'sign_in'}},
        signout:  { method: 'delete', params: { action: 'sign_out'}},
      });

      var Account = $resource('/webpos/account/:action', {}, {})

      var account = WebposConst.account.id ? WebposConst.account : null;

      function get(success){
        if(account){
          PermissionService.init(account);
          set_features(account.shop.features)
          if(success){ success(account) }
        }else{
          Account.get({}, function(resp){
            set_account(resp)
            PermissionService.init(account);
            if(success){ success(resp) }
          })
        }
      }

      function sign_in(account, success){
        Accounts.sign_in({}, {
          webpos_webpos_account: account
        }, function(resp){
          $rootScope.clear_cache()
          set_account(resp.account)
          PermissionService.init(resp.account);
          NotifyService.restart();
          if(success){ success(resp) }
        });
      }

      function sign_out(success){
        set_account(null)
        Accounts.signout({}, {}, function(resp){
          $rootScope.clear_cache()
          NotifyService.clear()
          set_account(null)
          PermissionService.destroy();
          $rootScope.go(WebposConst.login_path)
          $rootScope.reload()
          if(success){ success(resp) }
        });
      }

        $rootScope.has_menu_url = function(menu_url){
          var url_hash=[
            ["/webpos#/branches" , "/eat_in_hall", "model_eat_in_hall"],
            ["/webpos#/branches" , "/fast_food",  "model_fastfood"],
            ["/webpos#/branches" ,"/delivery",    "model_delivery"],
            ["/webpos#/branches" ,"/reservation", "model_reservation"],
            ["/webpos#/branches" ,"/payment",     "model_payment"],
            ["/webpos#/branches" ,"/orders",      "model_order"],
            ["/webpos#/branches" ,"/promotions",  "model_coupon_exchange"],
            ["/webpos/queue"     , "/queue",      "model_queue"],
            ["/webpos/estimate"  ,"/estimate",    "model_estimate_clear"],
            ["/webpos/users"     ,"/users",       "model_vip_info"],
            ["/webpos/bill"      , "/bill",       "model_bill_center"],
            ["/webpos/kitchen"     ,   "" ,       "model_kitchen"],
            ["/webpos#/branches" , "/printers",   "model_printer"]
          ]
          var flag = false;
          for ( k in url_hash) {
            if (menu_url.startsWith(url_hash[k][0])) {
              if (menu_url.includes(url_hash[k][1])) {
                if ($rootScope.has_feature(url_hash[k][2])) {
                  flag = true;
                }
              }
            }
          }
          return flag;
        }

      function set_account(new_account){
        account = new_account
        $rootScope.account = new_account
        $rootScope.set_shop(new_account ? new_account.shop : {})
        set_features(new_account ? new_account.shop.features : null)

      }

      function is_role(role_name, uniq){
        if (account) {
          var yes = account.roles.indexOf(role_name) !== -1;
          var only = account.roles.length == 1
          return yes && (!uniq || only)
        }else{
          return false;
        }
      }

      function destroy_ability(){
        PermissionService.destroy();
        set_features(null)
      }

      function set_features(features){
        $rootScope.features = features;
        $rootScope.has_feature = function(feature){
          if(!$rootScope.features){return true}
          return $rootScope.features.indexOf(feature) > -1
        }
      }


      return {
        get: get,
        sign_in: sign_in,
        sign_out: sign_out,
        is_role: is_role,
        destroy_ability: destroy_ability
      }
    }])
