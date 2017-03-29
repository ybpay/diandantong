angular.module('ddt_app.directives.cart_btn', [])
  .directive('cartMinusBtn', [function () {
    return {
      restrict: 'EA',
      replace: true,
      template: '<span class="fa-stack">'
                + '<i class="fa fa-circle-thin fa-stack-2x"></i>'
                + '<i class="fa fa-minus fa-stack-1x"></i>'
              + '</span>',
      link: function(scope, element, attrs){
      }
    }
  }]).directive('cartPlusBtn', [function () {
    return {
      restrict: 'EA',
      replace: true,
      template: '<span class="fa-stack">'
                + '<i class="fa fa-circle-thin fa-stack-2x"></i>'
                + '<i class="fa fa-plus fa-stack-1x"></i>'
              + '</span>',
      link: function (scope, iElement, iAttrs) {

      }
    };
  }])
