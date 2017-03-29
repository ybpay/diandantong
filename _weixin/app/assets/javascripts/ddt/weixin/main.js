
angular.module('ddt_main', Ddt.buildAppDependencies(
  [
    'ddt_app.route_config.main'
  ]
.concat(Base.requires)))
.config(Base.config.interceptors)
.config(Base.config.routes)
.config(Base.config.location)
.run(['$rootScope', '$timeout', '$location', '$route', '$routeParams','ShopService','DdtConst', 'HistoryUrlService', 'WechatShareRecordService','UserService',
  function($rootScope, $timeout, $location, $route, $routeParams, ShopService, DdtConst, HistoryUrlService, WechatShareRecordService, UserService){

    $rootScope.hide_menu_default = false;
    $rootScope = Base.init($rootScope, $route, $location, DdtConst, HistoryUrlService, WechatShareRecordService, UserService)

    $rootScope.is_submiting = false
    $rootScope.is_in_weixin = WeixinApi.openInWeixin();
    $rootScope.oauth_user_info_url = DdtConst.oauth_user_info_url;

    ShopService.get(function(shop){
      $rootScope.current_shop = shop;
      $rootScope.shop = shop;
      $rootScope.currency = shop.currency;
    });

    $rootScope.toggle_show_eat_in_hall_select = function(){
      $rootScope.show_eat_in_hall_select = !$rootScope.show_eat_in_hall_select;
    }

    $rootScope.scanQrCode = function(desc){
      if($rootScope.is_in_weixin) {
        wx.scanQRCode({
          desc: desc,
          needResult: 0, // 默认为0，扫描结果由微信处理，1则直接返回扫描结果，
          scanType: ["qrCode","barCode"], // 可以指定扫二维码还是一维码，默认二者都有
          success: function (res) {
            // var result = res.resultStr; // 当needResult 为 1 时，扫码返回的结果
          },
          fail : function(res){
              alert("商家所使用的普通订阅号不支持自动开启扫描器，请点击微信聊天主界面的扫一扫功能来进行扫码");
          }
        });
      }else{
        alert('您使用的不是手机端微信，无法扫码')
      }
    }

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


    $rootScope.bind_wechat_share_callback()
    //console.log(angular.module('ddt_main').requires);
    $rootScope.go_ng_path(function(){
      var shop = $rootScope.current_shop;
      if(shop.default_branch_id && !shop.is_single){
        $location.url('/branches/'+shop.default_branch_id);
      }
    })

}]);

