WebposModules.add_service('recharge_product')
angular.module('webpos.services.recharge_product', []).
  factory('RechargeProduct', ['$rootScope', '$resource',
    function($rootScope, $resource){
      return $resource('/recharge_products/:id/:action', {},{
        query:  { method: 'get', isArray: true, cache: true}
      });
    }])