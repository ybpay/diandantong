"use strict"
Ddt.controller('wechatShareRecordsController', [
  '$rootScope', '$route', '$scope', '$routeParams', 'WechatShareRecordService', 'LoadMoreServiceFactory',
  function($rootScope, $route, $scope, $routeParams, WechatShareRecordService, LoadMoreServiceFactory){
    $rootScope.title = "我的分享";
    $scope.wechat_share_records = []
    $scope.loadMoreService = LoadMoreServiceFactory.createLoadMoreService({
      id: $route.current.controller,
      onLoadMore: function(page, per_page, timestamp, success){
        WechatShareRecordService.query({
          page: page,
          per_page: per_page
        }, function(data){
          if(success) { success(data) }
        });
      },

      update: function(olds){
        $scope.wechat_share_records = olds;
      }
    });

    $(document).on('scroll', function(){
      if (!$scope.loadMoreService.isLoading()) {
        var scrollTop = $(document.documentElement).scrollTop() || $(document.body).scrollTop();
        if (scrollTop + $(window).height() > $(document).height() - 30) {
          $scope.loadMoreService.loadMore();
        }
      }
    });
  }
]).controller('wechatShareRecordController', [
'$rootScope', '$scope', '$routeParams', 'WechatShareRecordService',
function($rootScope, $scope, $routeParams, WechatShareRecordService){
  $rootScope.title = "分享详情";
  WechatShareRecordService.get($routeParams.wechat_share_record_id, function(wechat_share_record){
      $scope.wechat_share_record = wechat_share_record;
      $scope.item_groups = group_in(wechat_share_record.wechat_view_records, 4);
    });
}]);



