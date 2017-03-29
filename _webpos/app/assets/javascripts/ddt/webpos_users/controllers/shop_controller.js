WebposModules.add_controller('shop')
angular.module('webpos.controllers.shop', []).
  controller('ShopController', ['$scope', '$state',
    function($scope, $state){
      $scope.back = function(){
        $scope.back_to_webpos()
        // switch($state.current.state){
        //   case "shop.branches":
        //     $scope.back_to_webpos()
        //     break;
        //   case "shop.users":
        //     $state.go("shop.branches");
        //     break;
        //   case "shop.users.detail":
        //     $state.go("shop.users");
        //     break;
        // }
      }

      $scope.back_to_webpos = function(){
        window.location.href = window.location.origin + "/webpos"
      }

    }])