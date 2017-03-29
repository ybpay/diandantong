Ddt.directive('ddbOrderState', [function () {
    return {
      restrict: 'EA',
      replace: true,
      scope:{
        state: '@ddbState',
        active: '=ddbActive',
        hide_left: '=ddbHideLeft',
        hide_right: '=ddbHideRight'
      },
      template: '<div class="order-state" ng-class="{\'active\': active}">'
                + '<div class="order-state-header">'
                  + '<div class="square">'
                    +  '<div class="line-through" ng-hide="hide_left"></div>'
                  + '</div>'
                  + '<i class="weui_icon_success white"></i>'
                  + '<div class="square">'
                    +  '<div class="line-through" ng-hide="hide_right"></div>'
                  + '</div>'
                + '</div>'
                + '<div class="order-state-body">'
                  + '{{state}}'
                + '</div>'
              +'</div>',
      link: function(scope, element, attrs){
      }
    }
  }])