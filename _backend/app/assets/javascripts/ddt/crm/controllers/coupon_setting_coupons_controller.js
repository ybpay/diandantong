CrmModules.add_controller('coupon_setting_coupons')
angular.module('crm.controllers.coupon_setting_coupons', []).
  controller('CouponSettingCouponsController',
    ['$rootScope', '$scope','Coupon', '$mdDialog', 'Box', 'PaginateService',
    function($rootScope, $scope, Coupon, $mdDialog, Box, PaginateService){
      $scope.coupons = [];
      $scope.query_params = {};
      Coupon.query($scope.query_params).$promise.then(function(resp){
        $scope.coupons = resp
      })

      $scope.q = {
        id_eq: "",
        is_expired: false,
        base_user_id_or_base_user_phone_or_base_user_email_or_base_user_unique_user_nickname_cont: '',
      };

      function get_q(){
        params = {}
        for(var key in $scope.q) {
          params["q["+key+"]"] = $scope.q[key]
        }
        return params;
      }

      $scope.search = function(){
        $scope.p = PaginateService.init(Coupon.query, get_q(), function(coupons){
          $scope.coupons = coupons;
        })
        $scope.p.query()
      }
      $scope.search()

      $scope.new_coupon = function($event){

      }


    }
  ])
