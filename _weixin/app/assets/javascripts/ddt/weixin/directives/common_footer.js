Ddt.directive('commonFooter', ['$rootScope', '$location',function ($rootScope, $location) {
    return {
      restrict: 'EA',
      replace: true,
      template: '<div class="page-footer nav-item-bar">'+
                  '<a class="nav-item" ng-class="{\'active\': active_home_icon()}" ng-click="go_page(\'main\', \'/\')">' +
                    '<img ng-src="/images/ddt/common/index.png">' +
                    '<div class="nav-text">首页</div>' +
                  '</a>' +
                  '<a class="nav-item" ng-class="{\'active\': active_branches_search_icon()}" ng-click="go_page(\'main\', \'/branches_search\')" ng-if="!current_shop.is_single">' +
                    '<img ng-src="/images/ddt/common/search.png">' +
                    '<div class="nav-text">搜索</div>' +
                  '</a>' +
                  '<a class="nav-item" ng-class="{\'active\': active_branches_icon()}" ng-click="go_page(\'main\', \'/branches\')" ng-if="!current_shop.is_single">' +
                    '<img ng-src="/images/ddt/common/branches.png">' +
                    '<div class="nav-text">门店</div>' +
                  '</a>' +
                  '<a class="nav-item" ng-class="{\'active\': active_branch_icon()}" ng-click="go_page(\'main\', \'/branches/'+$rootScope.shop.default_branch_id+'\')" ng-if="current_shop.is_single">' +
                    '<img ng-src="/images/ddt/common/branches.png">' +
                    '<div class="nav-text">门店介绍</div>' +
                  '</a>' +
                  // '<a class="nav-item" ng-class="{\'active\': active_branch_icon()}" ng-click="go_page(\'main\', \'/branches/'+$rootScope.shop.default_branch_id+'\')" ng-if="current_shop.is_single">' +
                  //   '<img ng-src="/images/ddt/common/branches.png">' +
                  //   '<div class="nav-text">关注</div>' +
                  // '</a>' +
                  '<a class="nav-item" ng-class="{\'active\': active_user_icon()}" ng-click="go_page(\'my\', \'/user/profile\')">' +
                    '<img ng-src="/images/ddt/common/my.png">' +
                    '<div class="nav-text">我的</div>' +
                  '</a>' +
                '</div>',
      link: function(scope, element, attrs) {
        var path = $location.path()
        scope.active_home_icon = function(){
          if(['/'].indexOf(path) != -1){return true}
          return false;
        }
        scope.active_branches_icon = function(){
          if("/branches" === path){ return true}
          return false;
        }
        scope.active_branches_search_icon = function(){
          if("/branches_search" === path){ return true}
          return false;
        }
        scope.active_favourite_icon = function(){
          if('/favorite_branches' === path){return true}
          return false;
        }
        scope.active_branch_icon = function(){
          if(path.indexOf('/introduction')!=-1){return true}
          return false;
        }
        scope.active_user_icon = function(){
          if(['/my/','/user/coupon_nav', '/orders/nav','/contact_us'].indexOf(path) != -1){return true}
          return false;
        }
      }
    };
  }
]);
