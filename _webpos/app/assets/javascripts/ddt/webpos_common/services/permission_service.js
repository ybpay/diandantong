WebposModules.add_service('permission')
angular.module('webpos.services.permission', []).
  factory('PermissionService', ['$resource',
    function($resource){
      var Ability = $resource('/ability', {},{
          get:  { method: 'get', isArray: false}
        });

      var promise
      var permissions = {};

      function init(account){
        if (Object.keys(permissions).length <= 0) {
          permissions = account.permissions
        }
        return new Promise(function(resolve){
          resolve(permissions)
        });
      }

      function can(scope, target, action){
        return permissions && permissions[scope] && permissions[scope][target] && permissions[scope][target].indexOf(action) != -1
      }

      function destroy(){
        permissions = {}
      }

      return {
        init: init,
        can: can,
        destroy: destroy
      }
    }])
