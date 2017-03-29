WebposModules.add_service('temp_recharge_product')
angular.module('webpos.services.temp_recharge_product', []).
  factory('TempRechargeProduct', ['$rootScope', '$resource',
    function($rootScope, $resource){
      return $resource('/temp_recharge_products/:id/:action', {},{});
    }])