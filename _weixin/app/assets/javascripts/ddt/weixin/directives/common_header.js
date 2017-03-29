Ddt.module('ddt_app.directives.common_header', [])
.directive('commonHeader', ['$rootScope', function ($rootScope) {
    return {
      restrict: 'EA',
      replace: true,
      template: '<div class="ddb-nav-header">' +
                  '<div class="nav-left-item" ng-click="back()"><i class="fa fa-angle-left"></i></div>' +
                  '<div class="header-title">{{header_title}}</div>' +
                '</div>',
      link: function(scope, element, attrs) {
      }
    };
  }
]);
