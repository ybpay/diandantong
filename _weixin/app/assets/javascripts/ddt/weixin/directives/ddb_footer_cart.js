Ddt.module('ddt_app.directives.footer_cart', [])
  .directive('ddbFooterCart', ['$rootScope', 'SnapCartService', 'BaseCartService', 'CartAction',
    function ($rootScope, SnapCartService, BaseCartService, CartAction) {
    return {
      restrict: 'EA',
      scope: {
        cart_type: '@cartType',
        branch_id: '@branchId',
        check_stock: '=checkStock',
        snap: '=isSnap'
      },
      replace: true,
      templateUrl: '/weixin/client_partials/carts/ddb-footer.html' + version_timestamp,
      link: function(scope, element, attrs){
        scope.cart = null;
        scope.show_content = false;
        scope.currency = $rootScope.currency;

        scope.$watch("branch_id", function(o,n){
          if(scope.branch_id && scope.cart_type) {
            CartAction.action(scope);
          }
         });

        function cartChanged(e, cart){
          scope.cart = cart
        }

        //console.log('add listener')
        var clear_snap_cart_listener = scope.$on('cart:snap:change', cartChanged)
        var clear_cart_listener = scope.$on('cart:change', cartChanged)


        scope.$on('$destroy', function(){
          clear_snap_cart_listener();
          clear_cart_listener();
        })

        scope.toggle_content = function(){
          scope.show_content = !scope.show_content;
        }
      }
    }
  }]);
