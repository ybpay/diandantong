"use strict"

Ddt.controller('guestQueueController', [
  '$rootScope', '$scope', '$routeParams', 'GuestQueueService', 'BranchService', 'RefreshService',
  function($rootScope, $scope, $routeParams, GuestQueueService, BranchService, RefreshService){
    $rootScope.title = '微信排号';
    $scope.branch_id = $routeParams.branch_id
    BranchService.get({id: $scope.branch_id}, function(branch){
      $scope.branch = branch;
    });


    GuestQueueService.get($routeParams.branch_id, function(resp){
      $scope.queue_settings = resp.queue_settings;
      // if($scope.queue_settings.length > 0){
      //   $scope.guest_queue.queue_setting_id = $scope.queue_settings[0].id
      // }
      $scope.new_guest_queue = {};
    });

    $scope.submit = function(){
      if(!$scope.new_guest_queue.guest_num){
        $scope.$emit("events:receive_errors", '客人数量不能为空');
      }else{
        if(!$rootScope.is_submiting){
          $rootScope.is_submiting = true
          GuestQueueService.create($routeParams.branch_id, $scope.new_guest_queue, function(guest_queue){
            $scope.new_guest_queue = {};
            $rootScope.is_submiting = false;
            refresh_state();
          });
        }
      }
    }

    function init_items(){
      var btns = Base.newBtns()
      btns.push({
        img: '/images/ddt/queue/refresh.png',
        label: "刷新状态",
        func: refresh_state
       });

      btns.push({
        img: '/images/ddt/queue/cancel_queue.png',
        label: "取消排号",
        func: cancel
      });

      btns.push({
        img: '/images/ddt/my/eat_in_hall.png',
        label: "提前点菜",
        func: go_pre_ordering
       });

      btns.push({
        img: '/images/ddt/common/back.png',
        label: '返回门店',
        func: go_branch
      })

      $scope.item_group = btns.group();
    }

    function refresh_state(){
      GuestQueueService.get($scope.branch_id, function(guest_queue){
        $scope.guest_queue = guest_queue;
        if(guest_queue){
          init_items();
        }
      });
    }

    function cancel(){
      $rootScope.confirm('取消确认', '确认取消本次排号？', function(){
        GuestQueueService.cancel($scope.branch_id, function(){
          $scope.guest_queue = null;
          $scope.$emit('events:receive_errors', '已经成功取消排号');
        });
      })
    }

    function go_pre_ordering(){
      $rootScope.go_page('cart', '/branches/'+$scope.branch_id+'/products/queue_pre_ordering')
    }

    function go_branch(){
      $rootScope.go_page('main', '/branches/'+$scope.branch_id)
    }

    refresh_state();

    var refresh_fn = function(){
      if($scope.guest_queue && $scope.guest_queue.my_queue){
        refresh_state();
      }
    }
    RefreshService.add($scope, refresh_fn, 10000)

}]).controller('bindUserGuestQueueController', ['$scope', '$rootScope', '$routeParams', 'GuestQueueService', 'BranchService', 'UserService',
function($scope, $rootScope, $routeParams, GuestQueueService, BranchService, UserService){
  $rootScope.title = '排号绑定';
  $scope.guest_queue = {};
  $scope.branch_id = $routeParams.branch_id
  $scope.qr_code_id = $routeParams.qr_code_id

  BranchService.get({id: $scope.branch_id}, function(branch){
    $scope.branch = branch;
  });

  UserService.get(function(user){
    $scope.user = user
  })

  GuestQueueService.get_by_qr_code($scope.branch_id, $scope.qr_code_id, function(guest_queue){
    $scope.guest_queue = guest_queue;
    function go_guest_queue(){
      $rootScope.go("/branches/" + $scope.branch_id + '/guest_queue')
    }

    if($scope.guest_queue.workflow_state != "queueing"){
      $rootScope.alert("该排号" + $scope.guest_queue.workflow_state_name)
      go_guest_queue();
    }else{
      if(!$scope.guest_queue.base_user_id){
        GuestQueueService.bind_user($scope.branch_id, $scope.guest_queue.id, function(result){
          if(result.state){
            go_guest_queue();
          }else{
            $rootScope.alert(result.error)
            go_guest_queue();
          }
        })
      }else{
        if($scope.guest_queue.base_user_id == $scope.user.id){
          go_guest_queue();
        }else{
          $rootScope.alert("该排号已被其他人绑定")
          go_guest_queue();
        }
      }
    }
  })


}]);
