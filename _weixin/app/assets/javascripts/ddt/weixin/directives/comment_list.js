Ddt.directive('commentList', ['$location',
  function ($location) {
  return {
    restrict: 'EA',
    scope: {
      comments: '=ngComments'
    },
    replace: true,
    // templateUrl: '/weixin/client_partials/comments/comments.html' + version_timestamp,
    template: 
                '<div ng-repeat="comment in comments" class="comment-item weui_cell">'+
                  '<div class="weui_cell_primary">'+
                    '<div class="comment-info">'+
                        '<div class="nickname orange">{{comment.nickname}}<span class="dark-gray"> {{comment.created_at|moment}}</span></div>'+
                        '<div class="comment-level red">'+
                          '<i class="fa fa-star" ng-repeat="i in getNumber(comment.rating) track by $index"></i>'+
                          '<i class="fa fa-star-o" ng-repeat="i in getNumber(5-comment.rating) track by $index"></i>'+
                        '</div>'+
                      '</div>'+
                      '<div class="content">'+
                        '{{comment.content}}'+
                      '</div>'+
                      '<div ng-if="comment.comments!=null"  class="comment-reply">'+
                        '<div  class="comment-info">' +
                          '<div class="nickname">商家1回复<span class="dark-gray"> {{comment.comments[0].created_at|moment}}</span></div>'+
                        '</div>' +
                        '<div class="content">'+
                          '{{comment.comments[0].content}}'+
                        '</div>'+
                      '<div>'+
                    '</div>'+
                    '</div>'+
                '</div>',
    link: function(scope, element, attrs) {
      scope.getNumber = function(num){
        return new Array(Math.min(num, 5));
      }
    }
  }
}]);
