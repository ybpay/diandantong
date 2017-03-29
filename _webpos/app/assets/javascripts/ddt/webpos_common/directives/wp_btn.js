WebposModules.add_directive('wp_btn')
angular.module('webpos.directives.wp_btn', [])
  .directive('wpBtnLg', [function () {
    return {
      restrict: 'EA',
      transclude: true,
      replace: true,
      template: '<div class="wp-btn-block wp-btn-lg"><div class="text"><div class="overflow-hidden-text"  ng-transclude></div></div></div>',
      link: function(scope, element, attrs){
      }
    }
  }]).directive('wpBtnMd', [function () {
    return {
      restrict: 'EA',
      transclude: true,
      replace: true,
      template: '<div class="wp-btn-block wp-btn-md"><div class="text"><div class="overflow-hidden-text"  ng-transclude></div></div></div>',
      link: function(scope, element, attrs){
      }
    }
  }]).directive('wpBtn', [function () {
    return {
      restrict: 'EA',
      transclude: true,
      replace: true,
      template: '<div class="wp-btn-block wp-btn"><div class="text"><div class="overflow-hidden-text"  ng-transclude></div></div></div>',
      link: function(scope, element, attrs){
      }
    }
  }]).directive('wpBtnSm', [function () {
    return {
      restrict: 'EA',
      transclude: true,
      replace: true,
      template: '<div class="wp-btn-block wp-btn-sm"><div class="text"><div class="overflow-hidden-text" ng-transclude></div></div></div>',
      link: function(scope, element, attrs){
      }
    }
  }]).directive('wpBtnXs', [function () {
    return {
      restrict: 'EA',
      transclude: true,
      replace: true,
      template: '<div class="wp-btn-block wp-btn-xs"><div class="text"><div class="overflow-hidden-text"  ng-transclude></div></div></div>',
      link: function(scope, element, attrs){
      }
    }
  }]).directive('wpTableBtn',[function (){
    return {
      restrict: 'EA',
      replace: true,
      scope: {
        table: "="
      },
      template: '<div class="wp-btn-block wp-btn-table">' +
                  '<div class="text">' +
                    '<div class="table-msg  overflow-hidden-text">' +
                      '<span>{{::table.name}}{{table.guest_num_label}}</span><br />'+
                      '<span>{{table.workflow_state_name}}</span>'+
                    '</div>'+
                    '<div class="order-msg"  ng-show="table.order_amount">'+
                      '<span class="order-amount">{{table.order_amount}}</span>'+
                      '<span class="from-wechat" ng-show="table.is_from_wechat"></span>'+
                    '</div>'+
                  '</div>'+
                '</div>',
      link: function(scope, element, attrs){
      }
    }
  }]);
