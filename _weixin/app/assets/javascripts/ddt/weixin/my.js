angular.module('ddt_my', Ddt.buildAppDependencies(
  [
    'ddt_app.route_config.my'
  ]
.concat(Base.requires)))
.config(Base.config.interceptors)
.config(Base.config.routes)
.config(Base.config.location)
.run(['$location', '$route', '$rootScope', '$location', '$timeout', '$routeParams', 'ShopService', 'DdtConst', 'HistoryUrlService', 'WechatShareRecordService', 'UserService',
  function($location, $route, $rootScope, $location, $timeout, $routeParams, ShopService, DdtConst, HistoryUrlService, WechatShareRecordService, UserService){

    $rootScope.hide_menu_default = true;
    $rootScope = Base.init($rootScope, $route, $location, DdtConst, HistoryUrlService, WechatShareRecordService, UserService)

    ShopService.get(function(shop){
      $rootScope.current_shop = shop;
      $rootScope.shop = shop;
      $rootScope.currency = shop.currency;
    });


    //console.log(angular.module('ddt_my').requires);
    $rootScope.bind_wechat_share_callback()
    $rootScope.go_ng_path();;

  }]);
