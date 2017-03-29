angular.module('ddt_order', Ddt.buildAppDependencies(
  [
    'ddt_app.route_config.order'
  ]
.concat(Base.requires)))
.config(Base.config.interceptors)
.config(Base.config.routes)
.config(Base.config.location)
.run(['$location', '$route', '$rootScope', '$location', '$timeout', '$routeParams','ShopService','UserService', 'DdtConst', 'HistoryUrlService', 'WechatShareRecordService',
  function($location, $route, $rootScope, $location, $timeout, $routeParams, ShopService,UserService, DdtConst, HistoryUrlService, WechatShareRecordService){

    $rootScope.is_in_weixin = WeixinApi.openInWeixin();
    $rootScope.hide_menu_default = true;
    $rootScope = Base.init($rootScope, $route, $location, DdtConst, HistoryUrlService, WechatShareRecordService, UserService)

    ShopService.get(function(shop){
      $rootScope.current_shop = shop;
      $rootScope.shop = shop;
      $rootScope.currency = shop.currency;
    });

    //console.log(angular.module('ddt_order').requires);

    $rootScope.view_branch_on_wechat_map = function(branch){
      wx.openLocation({
        latitude: parseFloat(branch.latitude), // 纬度，浮点数，范围为90 ~ -90
        longitude: parseFloat(branch.longitude), // 经度，浮点数，范围为180 ~ -180。
        name: branch.name, // 位置名
        address: branch.address, // 地址详情说明
        scale: 14, // 地图缩放级别,整形值,范围从1~28。默认为最大
        infoUrl: '' // 在查看位置界面底部显示的超链接,可点击跳转
      });
    }

    $rootScope.password_modal = {
      show: false,
      user: null,
      password: null,
      success: null,
      authenticate: function(){
        UserService.authenticate_password($rootScope.password_modal.password, function(resp){
          if(!resp.result){
            $rootScope.$emit("events:receive_errors", "支付密码错误")
          }else{
            if($rootScope.password_modal.success) { $rootScope.password_modal.success(); }
          }
        })
      },
      open: function(success){
        UserService.get(function(user){
          $rootScope.password_modal.user = user
        })
        $rootScope.password_modal.success = success
        $rootScope.password_modal.password = null
        $rootScope.password_modal.show = true
        $("input.password-modal-input").select()
      },
      close: function(){
        $rootScope.password_modal.success = null
        $rootScope.password_modal.password = null
        $rootScope.password_modal.show = false
      }
    }

    $rootScope.bind_wechat_share_callback()
    $rootScope.go_ng_path();

  }]);
