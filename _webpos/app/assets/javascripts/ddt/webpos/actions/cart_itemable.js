WebposModules.add_action('cart_itemable')
angular.module('webpos.actions.cart_itemable', []).
  factory('CartItemableAction', ['$rootScope', '$timeout','SetItemNoteAction', 'VariantPackageService', 'EditLineItemAction', 'DeliveryCartService','FastfoodCartService','TableCartService',
    function($rootScope, $timeout, SetItemNoteAction, VariantPackageService, EditLineItemAction, DeliveryCartService, FastfoodCartService, TableCartService){

    var branch_id = undefined;
    var callback = undefined;
    var cart_type = undefined;
    var service = undefined;
    function init(bid, ctype, cb){
      branch_id = bid;
      cart_type = ctype;
      callback = cb;
      switch(ctype){
        case "table":    service = TableCartService; break;
        case "delivery": service = DeliveryCartService; break;
        case "fastfood": service = FastfoodCartService; break;
      }
      SetItemNoteAction.init()
      if(ctype != 'table'){
        TableCartService.set_table_id(undefined);
      }
      TableCartService.get(branch_id,function(cart){
        if (cart.line_items.length > 0) {
          $rootScope.confirm("该桌台购物车中有部分选好的菜品尚未落单，是否恢复购物车？", function(){
            
          }, "恢复", function(){
            service.clear(branch_id, function(cart){
              callback(cart)
            })
          }, "清除")
        }
      })
    }

    function dispose(){
      branch_id = undefined;
      callback = undefined;
      cart_type = undefined;
      service = undefined;
      SetItemNoteAction.dispose()
    }

    function change_active_line_item(line_item){
      service.get(branch_id, function(cart){
        angular.forEach(cart.line_items, function(item){
          item.active = (item == line_item)
        })
        callback(cart)
      })
    }

    function add_itemable(itemable){
      service.add_itemable(branch_id, itemable, function(cart, item){
        change_active_line_item(item)
      })
    }

    function add_itemable_separate(itemable){
      if(itemable.is_by_weight){
        VariantPackageService.create(branch_id, itemable, itemable.default_weight, function(variant_package){
          service.add_itemable_separate(branch_id, variant_package, function(cart, line_item){
            angular.forEach(cart.line_items, function(item){
              item.active = (item == line_item)
            })
            change_weight(line_item);
            $rootScope.$broadcast("event:choose_itemable:handle_finish")
          })
        });
      }else{
        service.add_itemable_separate(branch_id, itemable, function(cart, line_item){
          angular.forEach(cart.line_items, function(item){
            item.active = (item == line_item);
            setTimeout(function(){ item.active = false },2000)
          })
          $rootScope.$broadcast("event:choose_itemable:handle_finish")
          callback(cart)
        })
      }
    }

    function remove_itemable(itemable){
      service.remove_itemable(branch_id, itemable, function(cart){
        callback(cart)
      })
    }

    function clear(){
      $rootScope.confirm("确定要清除已经选好的菜品吗？", function(){
        service.clear(branch_id, function(cart){
          callback(cart)
        })
      });
    }

    function clearWithoutConfirm(){
      service.clear(branch_id, function(cart){
          callback(cart)
        })
    }

    function change_note(line_item){
      $rootScope.item_notes_modal.open(line_item.note, function(note){
        service.change_note(branch_id, line_item, note, function(cart){
          callback(cart)
        })
      })
    }

    function batch_change_note(){
      $rootScope.item_notes_modal.open('', function(note){
        service.get(branch_id, function(cart){
          angular.forEach(cart.line_items, function(line_item){
            var all_note = note;
            if(line_item.note != ""){
              all_note = line_item.note +" "+ all_note
            }
            service.change_note(branch_id, line_item, all_note, function(cart){
              callback(cart)
            })
          })
        })
      })
    }

    function change_gift(line_item){
      if(line_item.gift){
        line_item.gift = false
        line_item.gift_reason = ""
      }else{
        $rootScope.auth_action('branch', 'order', 'gift_item', { branch_id: branch_id }, function(){
          $rootScope.clear_authorizer()
          $rootScope.gift_reasons_modal.open(function(reason){
            line_item.gift = true
            line_item.gift_reason = reason
          })
        })
      }
    }

    function change_weight(line_item){
      $rootScope.change_weight_modal.open(line_item, function(line_item, weight){
        VariantPackageService.update(branch_id, {id: line_item.itemable_id, weight: weight}, function(variant_package){
          service.update_itemable(branch_id, variant_package, function(cart){
            callback(cart)
          });
        });
      });
    }

    function edit_line_item(line_item){
      EditLineItemAction.action(line_item, function(new_line_item){
        if(new_line_item.is_by_weight){
          params = {
            id: new_line_item.itemable_id,
            weight: new_line_item.weight
          }
          if(new_line_item.new_variant){
            params.variant_id = new_line_item.new_variant.id
          }
          VariantPackageService.update(branch_id, params, function(variant_package){
            service.update_itemable(branch_id, variant_package, function(cart){
              callback(cart)
            })
          })
        }else{
          service.update_itemable(branch_id, line_item, function(cart){
            callback(cart)
          })
        }

      })
    }

    return {
      init: init,
      dispose: dispose,
      change_active_line_item: change_active_line_item,
      add_itemable: add_itemable,
      add_itemable_separate: add_itemable_separate,
      remove_itemable: remove_itemable,
      clear: clear,
      clearWithoutConfirm: clearWithoutConfirm,
      change_weight: change_weight,
      change_note: change_note,
      batch_change_note: batch_change_note,
      change_gift: change_gift,
      edit_line_item: edit_line_item
    }
  }]);
