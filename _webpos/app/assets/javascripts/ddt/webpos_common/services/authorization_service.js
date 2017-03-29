WebposModules.add_service('authorization')
angular.module('webpos.services.authorization', []).
  factory('AuthorizationService', ['$rootScope', '$resource', 'LocalStorageCache',
    function($rootScope, $resource, LocalStorageCache){
      // var current_id = null;
      var Authorization = $resource('/webpos/account/:action', {},{
        get_authorizers: { method: 'get', params: {action: "get_authorizers"}, isArray: true},
        bosses_and_workers: { method: 'get', params: {action: 'bosses_and_workers'}, isArray: true},
        auth: {method: 'post', params: {action: 'authorization'}}
      });

      function get_authorizers(params, success){
        Authorization.get_authorizers(params, success)
      }

      function bosses_and_workers(success){
        Authorization.bosses_and_workers({}, success)
      }

      function auth(account_id, password, success, fail){
        Authorization.auth({},{auth_id: account_id, password: password}, function(result){
          if(result.ok){
            LocalStorageCache.set("current_authorizer_id", account_id)
            success();
          }else{
            LocalStorageCache.set("current_authorizer_id", null)
            fail();
          }
        })
      }

      function init_modal(){
        $rootScope.authorization_modal = {
          show: false,
          boss: [],
          password: null,
          selected_boss: null,
          init: function(){
            this.show=false;
            this.password = null;
          },
          action: function(){},
          submit: function(){
            if(this.can_submit()){
              auth(this.selected_boss.id, this.password, function(){
                $rootScope.authorization_modal.action(true);
                $rootScope.authorization_modal.init();
              }, function(){
                $rootScope.alert("密码不正确");
              })
            }else{
              $rootScope.alert("请确保输入正确");
            }
          },
          chose_boss: function(boss){
            this.selected_boss = boss;
          },
          can_submit: function(){
            return this.selected_boss && this.password != "" && this.password != null
          },
          close: function(){
            this.init();
          }
        }
      }

      function auth_action(scope, target, action, options, callback){
        if($rootScope.can(scope, target, action)){
          if (callback) {
            callback(false);
          }
        }else{
          init_modal()
          get_authorizers({
            auth_scope: scope,
            auth_target: target,
            auth_action: action,
            auth_options: options
          }, function(bosses){
            var modal = $rootScope.authorization_modal;
            modal.bosses = bosses;
            modal.selected_boss = bosses[0];
            modal.action = callback;
            modal.show = true;
          })
        }
      }

      function current_authorizer_id(){
        return LocalStorageCache.get("current_authorizer_id");
      }

      function clear_authorizer(){
        LocalStorageCache.set("current_authorizer_id", null)
      }

      return {
        auth_action: auth_action,
        current_authorizer_id: current_authorizer_id,
        clear_authorizer: clear_authorizer
      }
    }])
