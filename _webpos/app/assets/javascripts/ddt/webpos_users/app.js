var App = angular.module('webpos_users', WebposModules.get([
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
App.run(['$rootScope', 'TemplateService', 'AccountService','Box','NotifyService','$location','$cacheFactory','PermissionService','RouteConfig','LocalStorageCache','$http','$interval','$route','$state','ExtendedFormService','$timeout','VerifyVipInfoService','AuthorizationService',
  function($rootScope, TemplateService, AccountService, Box, NotifyService, $location, $cacheFactory, PermissionService,RouteConfig, LocalStorageCache,$http, $interval, $route, $state, ExtendedFormService, $timeout, VerifyVipInfoService, AuthorizationService){

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
      NotifyService.restart()
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
      return "/webpos/templates_users/" + partial_name + ".html";
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

    // 扫码
    $rootScope.scan_modal = {
      show: false,
      show_input: false,
      code: "",
      title: "",
      info: "",
      action_name: "",
      success: function(){
        this.close()
        if(this.success_callback){ this.success_callback(this.code)}
      },
      success_callback: function(){},
      action: function(){
        this.close()
        if(this.action_callback){ this.action_callback()}
      },
      action_callback: function(){},
      add_code: function(c){ this.code += c;},
      toggle_input: function(){
        this.show_input = !this.show_input
        if(this.show_input){
          $rootScope.focus(".scan-modal-code input")
        }
      },
      open: function(){
        this.show = true;
        this.show_input = false;
        this.code = "";
      },
      close: function(){ this.show = false; },
    }

    $rootScope.scan = function(title, info, success_callback, action_name, action_callback){
      $rootScope.scan_modal.code = ""
      $rootScope.scan_modal.title = title
      $rootScope.scan_modal.info = info
      $rootScope.scan_modal.success_callback = success_callback
      $rootScope.scan_modal.action_name = action_name
      $rootScope.scan_modal.action_callback = action_callback
      $rootScope.scan_modal.open()
      $("input").blur()
      $timeout(function(){
        ExtendedFormService.show_hint(info)
      }, 500)
    }

    $(document).on("keydown", function(e){
      if($rootScope.scan_modal.show){
        // 扫码
        var tag = $(e.target)[0].localName
        var code = e.keyCode
        var ENTER = 13,
            ZERO  = 48,
            NINE  = 57,
            NUMPAD_ZERO = 96,
            NUMPAD_NINE = 105,
            DC1 = 17, // Device Control 1 (oft. XON) [ Left Control ]
            J = 74;
        if(code == ENTER){
          $rootScope.scan_modal.success();
        }else if(tag != "input" && code >= ZERO && code <= NINE){
          $rootScope.scan_modal.add_code(code - ZERO);
        }else if(tag != "input" && code >= NUMPAD_ZERO && code <= NUMPAD_NINE){
          $rootScope.scan_modal.add_code(code - NUMPAD_ZERO)
        }else if(code == DC1 || code == J){
          // 扫描枪在enter 之后又加了 Ctrl + j, 在chrome下是打开下载的快捷键，屏蔽这个组合键
          e.preventDefault();
        }
        $rootScope.$apply();
      }else{
        var top_modal_key = ({
          13: 'enter',
          27: 'esc',
        })[e.keyCode]
        if(top_modal_key){
          //priority3: hotkeys of confirm_modal
          //priority2: hotkeys of normal_modal
          //priority1: hotkeys of base
          hotkey_p3.trigger(e) && hotkey_p2.trigger(e) && hotkey_p1.trigger(e)
        }else{
          hotkey_p2.trigger(e) && hotkey_p1.trigger(e)
        }
      }
    })


    // 会员扫码识别
    $rootScope.vip_scan_verify = function(title, hint, success, enable_reload, only_vip){
      $rootScope.vip_scan_modal.title = title
      $rootScope.vip_scan_modal.hint = hint
      $rootScope.vip_scan_modal.enable_reload = enable_reload
      $rootScope.vip_scan_modal.scan_success = false
      $rootScope.vip_scan_modal.only_vip = only_vip
      $rootScope.vip_scan_modal.open()
      VerifyVipInfoService.verify(function(qrcode_url){
        $rootScope.vip_scan_modal.qrcode_url = qrcode_url
        ExtendedFormService.show_qrcode(hint, qrcode_url)
      }, function(vip_info){
        success(vip_info)
        $rootScope.vip_scan_modal.close();
      }, function(){
        $rootScope.vip_scan_modal.scan_success = true
      }, only_vip)
    }
    $rootScope.vip_scan_modal = {
      show: false,
      title: "",
      hint: "",
      qrcode_url: null,
      enable_reload: false,
      scan_success: false,
      only_vip: false,
      open: function(){ this.show = true },
      close: function(){
        this.show = false
        NotifyService.remove_message_handler("VERIFY_VIPINFO")
        NotifyService.remove_message_handler("VERIFY_VIPINFO_SCAN_SUCCESS")
      },
      reload_qrcode: function(){
        VerifyVipInfoService.reload_qrcode(function(qrcode){
          $rootScope.vip_scan_modal.qrcode_url = qrcode.url
        }, this.only_vip)
      }
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
