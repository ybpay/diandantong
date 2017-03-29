Ddt.module('ddt_app.directives.rating_stars', [])
.directive('ratingStars', ['$location',
  function ($location) {
    return {
      restrict: 'EA',
      scope: {
        rating: '=ngRating'
      },
      replace: true,

      template: '<div>' +
                  '<i class="fa fa-star" ng-repeat="i in getRating(rating) track by $index"></i>' +
                  '<i class="fa fa-star-o" ng-repeat="i in getRating(5 - rating) track by $index"></i>' +
                '</div>',

      link: function(scope, element, attrs) {
        scope.getRating = function(num) {
          return new Array(Math.min(num||0, 5));
        };
      }
    };
  }
]);
