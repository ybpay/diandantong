angular.module('ddt_queue', Ddt.buildAppDependencies(
  [
    'ddt_app.route_config.queue',
    'ddt_app.constants',
    'ddt_app.services.user'
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
    });

    $rootScope.go = function(path){
      $location.path(path);
    }

    //console.log(angular.module('ddt_queue').requires);
    $rootScope.go_ng_path();
  }]);
