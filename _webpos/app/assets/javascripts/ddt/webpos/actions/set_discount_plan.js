
WebposModules.add_action('set_discount_plan');
angular.module('webpos.actions.set_discount_plan', [])
  .factory('SetDiscountPlanAction',
    ['$rootScope', '$routeParams', 'HotkeyService', 'BaseOrderService', 'DiscountPlanService',
    function($rootScope, $routeParams, HotkeyService, BaseOrderService, DiscountPlanService){

      //
      //_plan callbacks: :order_changed, :moling, :cancel_moling
      //
      function init(get_order){
        var _plan = {collection: []};
        _plan.get_order = get_order;
        _plan.show_select_btn = function(){
          return this.collection && this.collection.length > 0 && this.get_order() && 'paid' != this.get_order().pay_item_state && !this.get_order().has_discount_plan
        }
        _plan.show_cancel_btn = function(){
          return this.collection && this.collection.length > 0 && this.get_order() && 'paid' != this.get_order().pay_item_state && this.get_order().has_discount_plan
        }
        _plan.init = function(){
          DiscountPlanService.query($routeParams.branch_id, function(discount_plans){
            _plan.collection = discount_plans
            _plan.bind_discounts_hotkey();
          })
        }
        _plan.bind_discounts_hotkey = function(){
          this.hotkey = HotkeyService.get_key('discount_plan');
          this.unbind_hotkey_discount_btn = $rootScope.bind_key(_plan.hotkey, function(){
            if(_plan.show_select_btn()){
              _plan.modal.open();
            }
            if(_plan.show_cancel_btn()){
              _plan.cancel();
            }
          })
          var unbinds = [];
          angular.forEach(_plan.collection, function(plan, index){
            if(index <12){
              var k = 'F'+(index + 1)
              plan.hotkey = k
              unbinds.push(
                hotkey_p2.bind({
                  key: k,
                  action: function(){
                    if(_plan.modal.show){
                      _plan.modal.select (plan);
                      return false;
                    }
                  }
                })
              )
            }
          })
          this.unbind_hotkey_of_discount_plans = unbinds;
        }

        _plan.unbind_hotkeys = function(){
          angular.forEach(this.unbind_hotkey_of_discount_plans, function(unbind){
            unbind();
          });
          if(this.unbind_hotkey_discount_btn){
            this.unbind_hotkey_discount_btn();
          }
        }
        _plan.modal = {
          show: false,
          open:  function(){
            this.show = true
          },
          close: function(){
            this.show = false;
          },
          select: function(plan){
            BaseOrderService.add_discount_plan(_plan.get_order().type_str, $routeParams.branch_id, _plan.get_order().id, plan.id, function(order){
              if(_plan.order_changed){
                _plan.order_changed(order)
              }
              _plan.modal.close()
            })
          }
        }
        _plan.cancel = function(){
          $rootScope.confirm("确定取消折扣方案？", function(){
            BaseOrderService.cancel_discount_plan(_plan.get_order().type_str, $routeParams.branch_id, _plan.get_order().id, function(order){
              if(_plan.order_changed){
                _plan.order_changed(order)
              }
            })
          })
        }
        _plan.destroy = function(){
          _plan.unbind_hotkeys();
          _plan = undefined;
        }
        _plan.init();
        return _plan;
      }

      return {
        init: init
      }
    }])
