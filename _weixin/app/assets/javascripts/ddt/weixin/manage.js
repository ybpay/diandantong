angular.module('ddt_manage', Ddt.buildAppDependencies(
  [
    'ddt_app.route_config.manage'
  ]
.concat(Base.requires)))
.config(Base.config.interceptors)
.config(Base.config.routes)
.config(Base.config.location)
.run(['$location', '$route', '$rootScope', '$location', '$timeout', '$routeParams', 'ShopService', 'DdtConst', 'HistoryUrlService', 'UserService',
  function($location, $route, $rootScope, $location, $timeout, $routeParams, ShopService, DdtConst, HistoryUrlService, UserService){

    $rootScope.hide_menu_default = false;
    $rootScope = Base.init($rootScope, $route, $location, DdtConst, HistoryUrlService, null, UserService)

    ShopService.get(function(shop){
      $rootScope.current_shop = shop;
      $rootScope.shop = shop;
      $rootScope.currency = shop.currency;
    });

    $rootScope.go_ng_path();
  }]);
