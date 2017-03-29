Ddt.controller('newOrderCommentController', [
  '$rootScope', '$scope', '$routeParams', '$timeout','OrderCommentService',
  function($rootScope, $scope, $routeParams, $timeout, OrderCommentService) {
    $rootScope.title = '订单评论';
    $scope.comment = {
      content: '',
      rating: 5
    };

    $scope.change_rating = function(rating) {
      var stars = $('.fa.rating-star');
      stars.slice(0, rating).each(function(i, n) { $(n).removeClass('fa-star-o').addClass('fa-star'); });
      stars.slice(rating).each(function(i, n) { $(n).removeClass('fa-star').addClass('fa-star-o'); });

      $scope.comment.rating = rating;
    };

    $scope.can_submit = function() {
      return $scope.comment.content;
    };

    $scope.submit = function() {
      if ($scope.can_submit()) {
        OrderCommentService.create($routeParams.branch_id, $routeParams.order_id, $scope.comment, function() {
          $scope.$emit("events:success_info", "恭喜，评论已提交");
          $timeout(function(){
            $rootScope.go_page('main', '/branches/'+$routeParams.branch_id)
          }, 2000)
        });
      }else{
        $scope.$emit("events:receive_errors", "评论内容不能为空")
      }
    };

  }
]);
