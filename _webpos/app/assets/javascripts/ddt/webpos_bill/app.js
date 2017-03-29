var App = angular.module('webpos_bill', WebposModules.get([
  'ngRoute','ngResource', 'ngCookies', 'ui.router', 'webpos.constants', 'errorReporter', 'ngKeypad', 'ngDraggable'
]));
App.config(['$httpProvider', 'InterceptorProvider',
  function($httpProvider, InterceptorProvider){
    var all_interceptors = InterceptorProvider.$get().get()
    angular.forEach(all_interceptors, function(interceptor){
      $httpProvider.interceptors.push(interceptor);
    })
}]);
App.config(['$stateProvider', '$urlRouterProvider', 'RouteConfigProvider',
  function ($stateProvider, $urlRouterProvider, RouteConfigProvider) {
  var all_configs = RouteConfigProvider.$get().get()
  angular.forEach(all_configs, function(conf){
    $stateProvider.state(conf.state, conf);
  });
  $urlRouterProvider.otherwise('/shop/branches');
}]);
App.run(['$rootScope','TemplateService', 'AccountService','Box','NotifyService','$location','$cacheFactory','PermissionService','LocalStorageCache','$http','$interval','$route','$state','RouteConfig','$timeout','AuthorizationService',
  function($rootScope, TemplateService,  AccountService, Box, NotifyService, $location, $cacheFactory, PermissionService, LocalStorageCache,$http, $interval, $route, $state, RouteConfig,$timeout, AuthorizationService){

    if(!$rootScope.terminal_id){
      $rootScope.terminal_id = "rs" + Date.parse(new Date());
    }
   $rootScope.$on('$stateChangeStart', function(event, toState, toParams, fromState, fromParams) {
        webposCommon.permit_enter(window,toParams,$rootScope)
       var feature = toState.feature
        if (!($rootScope.has_feature(feature))) {
             event.preventDefault();
        }
    });
    $rootScope.can = PermissionService.can;
    AccountService.get(function(account){
      $rootScope.account = account
      $rootScope.shop = account.shop
    })

    $rootScope.base_url = function(){ return "/webpos/shops/" + $rootScope.shop.slug }
    $rootScope.env = WebposConst.env
    $rootScope.alert = Box.alert

    $rootScope.$on('event:loginRequired', function(){
      $rootScope.account = null;
      $rootScope.clear_cache()
      NotifyService.clear()
      PermissionService.destroy();
      $rootScope.go_path("/webpos")
    });
    $rootScope.clear_cache = function(){
      if($cacheFactory.get("$http")){$cacheFactory.get('$http').removeAll();}
      if($cacheFactory.get("webpos")){$cacheFactory.get('webpos').removeAll();}
    }

    $rootScope.set_shop = function(shop){
      $rootScope.shop = shop
    }
    $rootScope.set_branch = function(branch){
      $rootScope.branch = branch
      $rootScope.branch_id = (branch ? branch.id : null)
    }

    $rootScope.is_self_message = function(msg){ return msg.terminal_id == $rootScope.terminal_id}
    $rootScope.is_not_self_message = function(msg){ return msg.terminal_id != $rootScope.terminal_id}
    $rootScope.reload = function(bool){ if(bool){ location.reload() }else{ $state.reload()}}
    $rootScope.go = function(url){
      $location.url(url)
    }
    $rootScope.go_path = function(path){
      window.location.href = window.location.origin + path
    }

    $rootScope.enable_jvk = LocalStorageCache.get("enable_jvk")
    $rootScope.toggle_jvk = function(){
      $rootScope.enable_jvk = !$rootScope.enable_jvk;
      LocalStorageCache.set("enable_jvk", $rootScope.enable_jvk)
    }

    $rootScope.partial = function(partial_name){
      return "/webpos/templates_bill/" + partial_name + ".html";
    }

    $rootScope.sign_out = function(){
      Box.confirm("确定退出?", function(){
        AccountService.sign_out()
      })
    }

    $rootScope.isLoading = function () {
       return $http.pendingRequests.length !== 0;
    };

    //设置系统时间
    function set_sys_time(){
      var system_time = $('meta[name="system_time"]').attr("content")
      if (Math.abs(system_time - Date.now() > 300000)) {
        $rootScope.alert("提示: 服务器时间和您客户端本地时间相差超过5分钟,请手动校正客户端本地时间（注：显示时间以本地时间为准）")
      };
      var refresh_time = function(){
        $rootScope.system_time = Date.now()
      }
      $interval(refresh_time,1000)
    };
    set_sys_time()

    $rootScope.focus = function(selector){
      setTimeout(function(){
        var dom = $(selector)[0];
        if(dom){ dom.focus()}
      }, 200)
    }

    //获取焦点
    $rootScope.focus = function(selector){
      setTimeout(function(){
        var dom = $(selector)[0];
        if(dom){ dom.focus()}
      }, 200)
    }

    // 权限验证
    $rootScope.auth_action = AuthorizationService.auth_action;
    $rootScope.current_authorizer_id = AuthorizationService.current_authorizer_id;
    $rootScope.clear_authorizer = AuthorizationService.clear_authorizer;

  }]);
