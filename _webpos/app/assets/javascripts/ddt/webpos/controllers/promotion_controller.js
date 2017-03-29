WebposModules.add_controller('promotion');
angular.module('webpos.controllers.promotion', []).
  controller('promotionController', ['$rootScope', '$scope', '$routeParams','BranchService','GrouponService', 'VoucherService', 'CouponService',
    function($rootScope, $scope, $routeParams,BranchService, GrouponService, VoucherService, CouponService){
      $scope.branch_id = $routeParams.branch_id;
      BranchService.get($scope.branch_id, function(branch){
        $scope.branch = branch
      })
      $scope.exchange_groupon = function(){
        $scope.promotion_type = 'groupon';
        show_input_form(find_groupon, do_exchange_groupon);
      }
      $scope.exchange_voucher = function(){
        $scope.promotion_type = 'voucher';
        show_input_form(find_voucher, do_exchange_voucher);
      }
      $scope.exchange_coupon = function(){
        $scope.promotion_type = 'coupon';
        show_input_form(find_coupon, do_exchange_coupon);
      }

      $scope.cancel = function(){
        $scope.input_exchange_code = false;
        $scope.exchange_code = null;
        $scope.show_promotion = false;
      }

      var show_input_form = function(search_action, exchange_action){
        $scope.search = search_action;
        $scope.exchange = exchange_action;
        $scope.input_exchange_code = true;
      }

      $scope.scan_code = function(){
        $rootScope.scan("扫码验券", "请顾客出示二维码，将扫描枪对准进行扫描。(注：扫描枪分一维码/二维码以及光敏/纸质类型，请灵活选择)", function(code){
          $scope.exchange_code = code;
          $scope.search()
        })
      }

      var exchange_success = function(promotion){
        $scope.exchange_code = null;
        $scope.input_exchange_code = false;
        $scope.show_promotion = false;
        $rootScope.alert("兑换成功！");
      }

      var find_success = function(promotion){
        $scope.promotion = promotion;
        $scope.show_promotion = true;
      }

      var find_groupon = function(){ find_base_coupon(GrouponService); }
      var find_voucher = function(){ find_base_coupon(VoucherService); }
      var find_coupon  = function(){ find_base_coupon(CouponService); }

      var do_exchange_groupon = function(){ exchange_by_code(GrouponService); }
      var do_exchange_voucher = function(){ exchange_by_code(VoucherService); }
      var do_exchange_coupon  = function(){ exchange_by_code(CouponService); }


      var find_base_coupon = function(service){
        service.find_by_code($scope.branch_id, $scope.exchange_code, function(base_coupon){
          find_success(base_coupon);
        })
      }
      var exchange_by_code = function(service){
        service.exchange_by_code($scope.branch_id, $scope.promotion.id, function(base_coupon){
          exchange_success(base_coupon);
        })
      }


    }])
