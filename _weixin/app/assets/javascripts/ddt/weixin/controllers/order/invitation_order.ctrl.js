Ddt.controller('invitationOrderController', [
  '$rootScope', '$scope', '$routeParams', '$location', 'WechatShareRecordService',
     'ShopService', 'BranchService', 'InvitationOrderService', 'UserService', 'DdtConst',
  function ($rootScope, $scope, $routeParams, $location, WechatShareRecordService,
      ShopService, BranchService, InvitationOrderService, UserService, DdtConst) {
    $scope.show_share_nav = false;

    UserService.get(function(user){
      $scope.user = user;
    });


    BranchService.get({id: $routeParams.branch_id}, function (branch) {
      $scope.branch = branch;
    });

    ShopService.get(function(shop) {
      $scope.shop = shop;
    });

    var order_params = {
      branch_id: $routeParams.branch_id,
      id: $routeParams.order_id,
      wechat_share_record_trigger_timestamp: UrlParser.query_parameter('wechat_share_record_trigger_timestamp')
    };


    InvitationOrderService.get(order_params, function(order){
      $scope.order = order;
      $scope.show_share_nav = order.is_my_order;
      if (!order.is_my_order) {
        if (order.opinion == null) {
          $scope.show_opinion_btn = true;
        } else {
          $scope.show_opinion_btn = false;
        }
        hideWechatShareMenus();
      }
      $scope.agree_guests = order.agree_guests;
      $scope.disagree_guests = order.disagree_guests
    });

    $rootScope.bind_wechat_share_callback();
    $rootScope.show_share_menu();
    $rootScope.shareRecordTrigger = {
      triggerBeforeCreateRecord: function(resp, cfg){
        var shareLink = '/branches/{branch_id}/orders/invitation/{order_id}'.supplant({
          branch_id: $routeParams.branch_id,
          order_id: $routeParams.order_id
        });
        var share_url = UrlParser.change_parameter(cfg.link, '_ng_path', shareLink);
        angular.extend(cfg, {
          title: '邀请函',
          desc: '我在' + $scope.branch.name + '预订了桌台，邀您一块举杯共聚吧',
          imgUrl: $rootScope.img_url('/images/ddt/yao.png'),
          link: UrlParser.change_parameter(DdtConst.oauth_user_info_url, 'redirect_uri', encodeURIComponent(share_url))
        });
      }
    };

    var hideWechatShareMenus = function(){
      // 对于非邀请者，隐藏掉分享等按钮
      wx.hideAllNonBaseMenuItem();
    }

    $scope.toggle_show_option_btn = function(){
      $scope.show_opinion_btn = !$scope.show_opinion_btn;
    }

    $scope.agree = function () {
      InvitationOrderService.agree(order_params, true, function (rc) {
        console.info(rc);
        $rootScope.reload();
      });
    }

    $scope.disagree = function () {
      InvitationOrderService.disagree(order_params, false, function (rc) {
        console.info(rc);
        $rootScope.reload();
      });
    }

    $scope.go_branch = function(){
      $rootScope.go_page('main', '/branches/'+$scope.branch.id)
    }

    $scope.go_map_link = function(){
      $rootScope.view_branch_on_wechat_map($scope.branch)
    }

    $scope.iknow = function(){
      console.log("iknow")
      $scope.show_share_nav = !$scope.show_share_nav;
    }

  }]);
