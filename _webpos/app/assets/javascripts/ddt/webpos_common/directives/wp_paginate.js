WebposModules.add_directive('wp_paginate')
angular.module('webpos.directives.wp_paginate', [])
  .directive('wpPaginate', [function() {
    return {
      restrict: 'EA',
      transclude: true,
      scope: {
        page_model: '=pageModel'
      },
      replace: true,
      template: '<div class="wp-paginate" ng-show="can_show()">'+
                  '<wp-btn ng-click="load_previous_page()" ng-class="{\'disabled\':!can_previous()}">上一页</wp-btn>'+
                  '<wp-btn class="disabled" ng-click="query()">第{{page_model.current_page()}}页</wp-btn>'+
                  '<wp-btn ng-click="load_next_page()" ng-class="{\'disabled\':!can_next()}">下一页</wp-btn>'+
                '</div>',
      link: function(scope, element, attrs){
        scope.can_show = function(){
          return scope.page_model && !scope.page_model.is_initing() && !scope.page_model.is_querying() && !(scope.page_model.current_page() == 1 && scope.page_model.is_last_page())
        }

        scope.can_previous = function(){
          return scope.page_model && scope.page_model.current_page() > 1
        }

        scope.can_next = function(){
          return scope.page_model && !scope.page_model.is_last_page()
        }

        scope.load_next_page = function(){
          if(scope.can_next()){ scope.page_model.next_page().query() }
        }

        scope.load_previous_page = function(){
          if(scope.can_previous()){ scope.page_model.previous_page().query() }
        }

        scope.query = function(){ scope.page_model.query() }
      }
    }
  }]);