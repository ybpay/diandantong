var CRM = angular.module('crm', CrmModules.get([
  'ngRoute','ngResource', 'ngCookies', 'ui.router', 'ngMaterial', 'crm.constants', 'nprogress-rails', 'ADM-dateTimePicker', 'rt.select2', 'ngFileUpload'
]));
CRM.config(['$httpProvider', 'InterceptorProvider',
  function($httpProvider, InterceptorProvider){
    var all_interceptors = InterceptorProvider.$get().get()
    angular.forEach(all_interceptors, function(interceptor){
      $httpProvider.interceptors.push(interceptor);
    })
}]);
CRM.config(['$stateProvider', '$urlRouterProvider', 'RouteConfigProvider',
  function ($stateProvider, $urlRouterProvider, RouteConfigProvider) {
  var all_configs = RouteConfigProvider.$get().get()
  angular.forEach(all_configs, function(conf){
    $stateProvider.state(conf.state, conf);
  });
  $urlRouterProvider.otherwise('/users/index');
}]);
CRM.config(["$mdThemingProvider", function($mdThemingProvider) {
  var valid_pelattes = ["red","pink","purple","deep-purple","indigo","blue","light-blue","cyan","teal","green","light-green","lime","yellow","amber","orange","deep-orange","brown","grey","blue-grey"]
  var hue = ["50, 100, 200, 300, 400, 500, 600, 700, 800, 900, A100, A200, A400, A700"]
  // primary - used to represent primary interface elements for a user
  // accent - used to represent secondary interface elements for a user
  // warn - used to represent interface elements that the user should be careful of
  // default
  // primary - indigo
  // accent - pink
  // warn - red
  // background - grey (note that white is in this palette)
  $mdThemingProvider
    .theme('default')
    .primaryPalette('blue', {})
    .accentPalette('grey',{})
    .warnPalette('orange',{})
    .backgroundPalette('grey',{
      'default': 'A100'
    })
}]);
CRM.config(['ADMdtpProvider', function(ADMdtp) {
  ADMdtp.setOptions({
    calType: 'gregorian',
    format: 'YYYY-MM-DD hh:mm',
    dtpType: 'date&time',
    multiple: false,
    transition: false
  });
}]);
CRM.run(['$rootScope','Shop','$mdSidenav','Box',
  function($rootScope,Shop,$mdSidenav,Box){

    Shop.get().$promise.then(function(shop){
      $rootScope.shop = shop
      $rootScope.account = shop.account
    })

    $rootScope.env = CrmConst.env
    $rootScope.alert = Box.alert

    $rootScope.menus = [
      {
        name: "会员",
        icon: "expand_more",
        active: false,
        pages: [
          { name: "用户列表", state: "users.index", active: false },
          { name: "会员设置", state: "vip_setting.vip_levels", active: false }
        ]
      },
      {
        name: "推广",
        icon: "expand_more",
        active: false,
        pages: [
          // { name: "团购设置", state: "home", active: false },
          { name: "优惠券设置", state: "coupon_setting.coupon_versions", active: false },
          { name: "积分设置", state: "credits_setting", active: false },
          { name: "充值设置", state: "recharge.products", active: false },
          // { name: "签到分享", state: "home", active: false },
        ]
      }
    ]

    $rootScope.toggleLeftMenu = function() {
      $mdSidenav('left').toggle();
    }

    $rootScope.toggleHideLeftMenu = function(){
      $("md-sidenav[md-component-id='left']").toggle()
    }

    $rootScope.page = {}

  }]);
