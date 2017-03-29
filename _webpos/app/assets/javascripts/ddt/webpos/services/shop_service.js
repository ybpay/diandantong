WebposModules.add_service('shop');
angular.module('webpos.services.shop', []).
service('ShopService',
  ['$resource', function($resource){
    var shop = null
    var Shop = $resource('/', {}, {});

    function get(success){
      if(shop){
        success(shop)
      }else{
        Shop.get({}, function(_shop){
          shop = _shop
          success(shop);
        })
      }
    }
    return {
      get: get
    }
  }])
