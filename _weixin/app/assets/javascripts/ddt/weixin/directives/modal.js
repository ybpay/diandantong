angular.module('ddt_app.directives.modal', [])
.directive('ngConfirmDialog', ['$compile', function ($compile) {
  return {
    restrict: 'EA',
    scope: {
      show: '=ngShow',
      title: '@ngTitle',
      confirm_text: '@ngConfirmText',
      cancel_text: '@ngCancelText',
      cancel_callback: '&ngCancel',
      confirm_callback: '&ngConfirm'
    },
    // replace: true,
    transclude: true,
    // template: '<div class="vc-confirm-modal"><div class="vc-confirm-modal-overlay"> &nbsp;</div><div class="vc-confirm-modal-offset"><div class="vc-confirm-modal-header">{{title}}<div class="close" ng-click="hideModal()"><i class="fa fa-times"></i></div></div><div class="vc-confirm-modal-body">{{body}}</div><div class="vc-confirm-modal-actions"><div class="btn confirm" ng-click="confirm_callback()">{{confirm_text||"确认"}}</div><div class="btn cancel" ng-click="cancel_callback()">{{cancel_text||"取消"}}</div></div></div></div>',
    template: '<div class="weui_dialog_confirm" ng-if="show">' +
                '<div class="weui_mask"></div>' +
                '<div class="weui_dialog">' +
                  '<div class="weui_dialog_hd"><strong class="weui_dialog_title">{{title||"提示"}}</strong></div>' +
                  '<div class="weui_dialog_bd" ng-transclude></div>' +
                  '<div class="weui_dialog_ft">' +
                    '<a href="javascript:;" class="weui_btn_dialog default" ng-click="hideModal() ; cancel_callback()">{{cancel_text || "取消"}}</a>' +
                    '<a href="javascript:;" class="weui_btn_dialog primary" ng-click="hideModal() ; confirm_callback()">{{confirm_text || "确认"}}</a>' +
                  '</div>' +
                '</div>' +
              '</div>',
    link: function(scope, element, attrs) {
      scope.hideModal = function(){
        scope.show =false;
        return true;
      }
    }
  };
}]).directive('ngAlertDialog', function () {
  return {
    restrict: 'EA',
    scope: {
      show: '=ngShow',
      title: '@ngTitle',
      confirm_text: '@ngClickText',
      confirm_callback: '&ngClick'
    },
    // replace: true,
    transclude: true,
    template: '<div class="weui_dialog_alert" ng-if="show">' +
                '<div class="weui_mask"></div>' +
                '<div class="weui_dialog">' +
                  '<div class="weui_dialog_hd"><strong class="weui_dialog_title">{{title||"提示"}}</strong></div>' +
                  '<div class="weui_dialog_bd" ng-transclude></div>' +
                  '<div class="weui_dialog_ft">' +
                    '<a href="javascript:;" class="weui_btn_dialog primary" ng-click="hideModal() && confirm_callback()">{{confirm_text || "我知道了"}}</a>' +
                  '</div>' +
                '</div>' +
              '</div>',
    link: function(scope, element, attrs) {
      scope.hideModal = function(){
        scope.show =false;
        return true;
      }
    }
  };
}).directive('ngTip', function () {
  return {
    restrict: 'EA',
    scope: {
      show: '=ngShow',
      title: '@ngTitle',
      confirm_text: '@ngClickText',
      confirm_callback: '&ngClick'
    },
    // replace: true,
    transclude: true,
    template: '<div class="weui_dialog_alert" ng-if="show&&showTip">' +
                '<div class="weui_mask" ng-click="hideModal()"></div>' +
                '<div class="weui_dialog">' +
                  '<div class="weui_dialog_hd"><strong class="weui_dialog_title">{{title||"提示"}}</strong></div>' +
                  '<div class="weui_dialog_bd" ng-transclude></div>' +
                  '<div class="weui_dialog_ft">' +
                    '<a href="javascript:;" class="weui_btn_dialog primary" ng-click="hideModal() && confirm_callback()">{{confirm_text || "我知道了"}}</a>' +
                  '</div>' +
                '</div>' +
              '</div>',
    link: function(scope, element, attrs) {
      scope.showTip = true
      scope.hideModal = function(){
        scope.showTip =false;
        return true;
      }
    }
  };
})