WebposModules.add_action('set_cancel_order')
angular.module('webpos.actions.set_cancel_order', []).
  factory('SetCancelOrderAction',
    ['$rootScope', '$routeParams', 'BaseOrderService',
      function($rootScope, $routeParams, BaseOrderService){
      var get_order = undefined;
      function init(gorder) {
        get_order = gorder
        set_modal()
      }

      function dispose(){
        get_order = undefined
        $rootScope.cancel_modal = undefined
      }
      function set_modal(){
        $rootScope.cancel_modal = {
          show: false,
          cancel_reason: "",
          other_reason: "",
          show_other_reason: false,
          change_reason: function (reason) {
            this.cancel_reason = reason;
            if (reason == "其他原因") {
              this.show_other_reason = true;
            } else {
              this.show_other_reason = false;
            }
          },
          can_submit: function () {
            return ("其他原因" != this.cancel_reason && this.cancel_reason && this.cancel_reason != "") ||
              ( "其他原因" == this.cancel_reason && this.other_reason && this.other_reason != "")
          },
          submit: function () {
            if(this.can_submit()){
              var cancel_reason = this.cancel_reason;
              if (cancel_reason == "其他原因") {
                cancel_reason = this.other_reason;
              }
              $rootScope.confirm("此操作不可逆，确定取消订单？", function () {
                var order_type = get_order().type_str;
                var order_id = get_order().id
                if(order_id){
                  BaseOrderService.cancel(order_type, $routeParams.branch_id, order_id, cancel_reason, function (order) {
                    $rootScope.clear_authorizer()
                    $rootScope.$broadcast("event:order:cancel", order)
                    $rootScope.cancel_modal.cancel();
                  })
                }else{
                  throw 'order_id not set in set_cancel_order.js'
                }

              })
            }
          },
          cancel: function () {
            this.show = false
          }
        }

      }

      function can_cancel_order() {
        return $rootScope.can('branch', 'order', 'cancel') && get_order() && (get_order().state === 'pending' || get_order().state === 'confirmed') && get_order().pay_item_state != 'paid'
      }

      function cancel_order(){
        $rootScope.auth_action('branch', 'order', 'cancel', { branch_id: $routeParams.branch_id }, function(){
          $rootScope.cancel_action_name = '取消'
          $rootScope.cancel_modal.show = true
        })
      }


      return {
        init: init,
        dispose: dispose,
        can_cancel_order: can_cancel_order,
        cancel_order: cancel_order
      }
    }]);
