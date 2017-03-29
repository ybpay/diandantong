Ddt.module('ddt_app.directives.common_header_shop', [])
.directive('commonHeaderShop', ['$rootScope', function ($rootScope) {
    return {
      restrict: 'EA',
      replace: true,
      template: '<div class="ddb-nav-header label-red">'+
                  '<div class="location-header left overflow-ellipsis">{{city_name||\'定位中\'}} <i class="fa fa-map-marker"></i></div>'+
                  '<a class="search-input-box" href="#/search" ng-if="!current_shop.is_single">'+
                    '<i class="fa fa-search"></i>'+
                    '寻找门店'+
                  '</a>'+
                '</div>',
      link: function(scope, element, attrs) {
      }
    };
  }
]);
