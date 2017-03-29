WebposModules.add_directive('wp_modal')
angular.module('webpos.directives.wp_modal', [])
  .directive('wpModal', ['$rootScope', function($rootScope) {
    return {
      restrict: 'EA',
      transclude: true,
      replace: true,
      scope: {
        wpShow: "=",
        wpLockMask: "=",
      },
      template: '<div class="wp-modal no-scroll" ng-show="wpShow">' +
                  '<div class="wp-modal-mask" ng-click="click_mask()"></div>' +
                  '<div class="wp-modal-body" ng-transclude>' +
                  '</div>'+
                '</div>',
      link: function(scope, element, attrs){

        var unbind_enter = null, unbind_esc = null;
        var clear_watch = scope.$watch('wpShow', function(newv, oldv){
          if(newv){
            unbind_enter = hotkey_p2.bind({key: 'enter', action: do_default_action})
            unbind_esc   = hotkey_p2.bind({key: 'esc',   action: close_modal})
          }else{
            $rootScope.$emit('modal:hide', 'normal_modal')
            unbind_hotkeys();
          }
        })

        function unbind_hotkeys(){
          if(unbind_enter){
            unbind_enter()
            unbind_enter = undefined
          }
          if(unbind_esc){
            unbind_esc()
            unbind_esc = undefined
          }
        }

        scope.$on('$destroy', function(){
          clear_watch();
          unbind_hotkeys();
        })

        scope.click_mask = function(){
          if((typeof scope.wpLockMask) == "undefined"){
            scope.wpShow = false;
          }else{
            if(!scope.wpLockMask){scope.wpShow = false;}
          }
        }

        function do_default_action(){
          if(scope.wpShow){ return !click_btn('.default-action')}
        }

        function close_modal(){
          if(scope.wpShow){
            if(!click_btn('.cancel-action')){
              scope.click_mask()
            }
            return false
          }
        }

        function click_btn(selector){
          var btn = $(element).find(selector)
          if(btn.length == 1){
            $(btn[0]).trigger('click')
            return true
          }
          return false
        }

      }
    }
  }])
  .directive('wpConfirmModal', ['$rootScope', function($rootScope) {
    return {
      restrict: 'EA',
      replace: true,
      scope: {
        wpShow: "=",
        wpLockMask: "=",
        wpConfirmInfo: "@",
        wpOkText: '@',
        wpCancelText: '@',
        wpOk: '&',
        wpCancel: '&'
      },
      template: '<div class="wp-modal wp-confirm-modal" ng-show="wpShow">'+
                  '<div class="wp-modal-mask" ng-click="click_mask()"></div>' +
                  '<div class="wp-modal-body">' +
                    '<div class="wp-modal-actions">' +
                      '<wp-btn class="default-action" ng-click="wpLockMask=false;wpOk();" ng-show="wpOkText">{{wpOkText}}</wp-btn>' +
                      '<wp-btn class="cancel-action" ng-click="wpLockMask=false;wpCancel();" ng-show="wpCancelText">{{wpCancelText}}</wp-btn>' +
                   ' </div>' +
                    '<div class="wp-modal-content wp-confirm-info" ng-bind-html="wpConfirmInfo|unsafe">' +
                    '</div>' +
                  '</div>'+
                '</div>',
      link: function(scope, element, attrs){

        var unbind_enter = null, unbind_esc = null;
        var clear_watch = scope.$watch('wpShow', function(newv, oldv){
          if(newv){
            unbind_enter = hotkey_p3.bind({key: 'enter', action: do_default_action})
            unbind_esc   = hotkey_p3.bind({key: 'esc',   action: close_modal})
          }else{
            $rootScope.$emit('modal:hide', 'confirm_modal')
            unbind_hotkeys();
          }
        })

        function unbind_hotkeys(){
          if(unbind_enter){unbind_enter()}
          if(unbind_esc){unbind_esc()}
        }

        scope.$on('$destroy', function(){
          clear_watch();
          unbind_hotkeys();
        })

        scope.click_mask = function(){
          if((typeof scope.wpLockMask) == "undefined"){
            scope.wpShow = false;
          }else{
            if(!scope.wpLockMask){scope.wpShow = false;}
          }
        }

        function do_default_action(){
          if(scope.wpShow){ return !click_btn('.default-action')}
        }

        function close_modal(){
          if(scope.wpShow){
            if(!click_btn('.cancel-action')){
              scope.click_mask()
            }
            return false;
          }
        }

        function click_btn(selector){
          var btn = $(element).find(selector)
          if(btn.length == 1){
            $(btn[0]).trigger('click')
            return true
          }
          return false
        }

      }
    }
  }])
  .directive('wpAlert', [function() {
      return {
        restrict: 'EA',
        transclude: true,
        replace: true,
        scope: {
          wpShow: "=",
          wpAlertInfo: "@"
        },
        template: '<div class="wp-alert-toast" ng-show="wpShow">'+
        '<div class="wp-alert-body" ng-bind-html="wpAlertInfo|unsafe">' +
        '</div>'+
        '</div>',
        link: function(scope, element, attrs){

        }
      }
  }])
