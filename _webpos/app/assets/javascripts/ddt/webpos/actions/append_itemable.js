WebposModules.add_action('append_itemable')
angular.module('webpos.actions.append_itemable', []).
  factory('AppendItemableAction',
    ['$rootScope', '$timeout', 'SetItemNoteAction', 'BaseOrderService', 'VariantPackageService', 'EditLineItemAction',
    function($rootScope, $timeout, SetItemNoteAction, BaseOrderService, VariantPackageService, EditLineItemAction){
      var append_itemables = []
      var branch_id = undefined;
      var get_order = undefined;
      var callback = undefined;
      var note = "";
      function init(bid, gorder, cb){
        branch_id = bid
        get_order = gorder
        callback = cb
        note = ""
        SetItemNoteAction.init()
        set_append_itemable_modal()
        append_itemables = []
        callback(append_itemables)
      }

      function dispose(){
        branch_id = undefined;
        get_order = undefined;
        callback = undefined;
        SetItemNoteAction.dispose()
        $rootScope.append_itemable_modal = undefined
      }

      function change_active_append_itemable(itemable){
        angular.forEach(append_itemables, function(item){
          item.active = (item.index == itemable.index)
        })
        callback(append_itemables)
      }

      function add_append_itemable(itemable, is_separate){
        var exist = false
        itemable.note = itemable.note || ""
        var current_item = undefined
        var min_quantity_for_order = itemable.min_quantity_for_order || 1
        if(!is_separate){
          angular.forEach(append_itemables, function(append_itemable){
            if(append_itemable.index == itemable.index){
              exist = true
              append_itemable.quantity ++
              current_item = append_itemable
            }
          })
        }

        var add_itemable = function(itemable, is_separate){
          if(!exist){
            var quantity = 1
            var ordered_quantity = get_quantity_in_order(itemable)
            /* 如果 ordered_quantity !=0 则说明这个产品已经在单里，已经过了 min_quantity_for_order 的检验*/
            if(ordered_quantity == 0){
              var appended_quantity = get_quantity_in_appends(itemable)
              if(appended_quantity + 1 < min_quantity_for_order){
                quantity = min_quantity_for_order - appended_quantity;
              }else{
                quantity = 1;
              }
            }
            var itemable = {
              index:         new Date().getTime(),
              itemable_id:   itemable.itemable_id,
              itemable_type: itemable.itemable_type,
              product_id:    itemable.product_id,
              name:          itemable.name,
              price:         itemable.price,
              note:          itemable.note || "",
              quantity:      quantity,
              min_quantity_for_order: min_quantity_for_order,
              is_by_weight: itemable.is_by_weight,
            }
            append_itemables.push(itemable)
            current_item = itemable
          }
          if(is_separate){
            $rootScope.$broadcast("event:choose_itemable:handle_finish")
          }
          return current_item
        }

        if(!exist && itemable.is_by_weight){
          VariantPackageService.create(branch_id, itemable, itemable.default_weight, function(variant_package){
            var item = add_itemable(variant_package, is_separate)
            change_weight(item);
          });
        }else{
          add_itemable(itemable, is_separate)
          callback(append_itemables)
        }
      }

      //private
      function get_quantity_in_appends(itemable){
        return get_quantity(append_itemables, itemable)
      }

      //private
      function get_quantity_in_order(itemable){
        return get_quantity(get_order().line_items, itemable)
      }

      //private
      function get_quantity(collection, itemable){
        var quantity = 0
        angular.forEach(collection, function(item){
          if(item.itemable_type == itemable.itemable_type
            && item.itemable_id == itemable.itemable_id){
            /* 有品注的产品存成不同的记录,  需累加*/
            quantity += item.quantity
          }
        })
        return quantity;
      }

      function remove_append_itemable(itemable){
        var index = append_itemables.indexOf(itemable)
        var min_quantity_for_order = itemable.min_quantity_for_order
        var need_adjust_index = false;
        ordered_quantity = get_quantity_in_order(itemable)
        appended_quantity= get_quantity_in_appends(itemable)
        if( (ordered_quantity + appended_quantity) - 1 < min_quantity_for_order){
          delete_appended_itemables(itemable);
          need_adjust_index = true;
        }else{
          itemable.quantity--;
          if(itemable.quantity === 0){
            need_adjust_index = true;
            append_itemables.splice(index, 1)
          }
        }
        if(need_adjust_index){
          append_itemables = adjust_index(append_itemables);
        }
        callback(append_itemables)
      }

      //private
      function adjust_index(line_items){
        angular.forEach(line_items, function(line_item, index){
          line_item.index = index;
        })
        return line_items;
      }

      //private
      function delete_appended_itemables(itemable){
        var result = [];
        angular.forEach(append_itemables, function(item, index){
          if( !(item.itemable_type == itemable.itemable_type && item.itemable_id == itemable.itemable_id)){
            result.push(item)
          }
        })
        append_itemables = result;
      }

      function can_append_itemables(){
        return append_itemables.length > 0
      }

      function confirm_append_itemables(){
        if(can_append_itemables()){
          $rootScope.append_itemable_modal.open();
        }else{
          $rootScope.alert("请选择添加的商品")
        }
      }

      function change_append_itemable_note(itemable){
        $rootScope.item_notes_modal.open(itemable.note, function(note){
          itemable.note = note
        })
      }

      function batch_change_append_itemable_note(){
        $rootScope.item_notes_modal.open('', function(note){
          angular.forEach(append_itemables, function(itemable){
            var all_note = note;
            if(itemable.note){
              all_note = itemable.note +" "+ all_note
            }
            itemable.note = all_note;
          });
        })
      }

      function change_append_itemable_gift(itemable){
        if(itemable.gift){
          itemable.gift = false
          itemable.gift_reason = ""
        }else{
          $rootScope.auth_action('branch', 'order', 'gift_item', { branch_id: branch_id }, function(){
            $rootScope.clear_authorizer()
            $rootScope.gift_reasons_modal.open(function(reason){
              itemable.gift = true
              itemable.gift_reason = reason
            })
          })
        }
      }

      function clear_append_itemables(force){
        if(force){
          append_itemables = []
          callback(append_itemables)
        }else{
          $rootScope.confirm("确定要清除已经选好的菜品吗？", function(){
            append_itemables = []
            callback(append_itemables)
          });
        }
      }

      function set_append_itemable_modal(){
        $rootScope.append_itemable_modal = {
          show: false,
          open: function(){
            var l = append_itemables.length;
            $rootScope.append_itemables_l = append_itemables.slice(0, l/2)
            $rootScope.append_itemables_r = append_itemables.slice(l/2)
            this.show = true
          },
          can_submit: function(){
            return !$rootScope.is_submiting && can_append_itemables();
          },
          submit: function(){
            if(!$rootScope.is_submiting){
              $rootScope.is_submiting = true
              BaseOrderService.append(get_order().type_str, branch_id, get_order().id, {
                itemables: append_itemables,
                note: note,
                is_local_printed: $rootScope.local_printer_configed()
              }, function(order){
                append_itemables = []
                $rootScope.append_itemable_modal.show = false;
                $rootScope.is_submiting = false
                callback(append_itemables)
                $rootScope.$broadcast("event:order:append_itemable:success", order)
              })
            }
          },
          cancel: function(){
            this.show = false;
          }
        }
      }

      function change_weight(item){
        $rootScope.change_weight_modal.open(item, function(line_item, weight){
          VariantPackageService.update(branch_id, {id: line_item.itemable_id, weight: weight}, function(itemable){
            item.name = itemable.name
            item.price = itemable.price
          });
        });
      }

      function change_note(new_note){
        note = new_note
      }

      function edit_line_item(item){
        EditLineItemAction.action(item, function(new_line_item){
          if(new_line_item.is_by_weight){
            params = {
              id: new_line_item.itemable_id,
              weight: new_line_item.weight
            }
            if(new_line_item.new_variant){
              params.variant_id = new_line_item.new_variant.id
            }
            VariantPackageService.update(branch_id, params, function(itemable){
              item.name = itemable.name
              item.price= itemable.price
              item.weight = itemable.weight
            })
          }else{
            item = new_line_item
          }
        })
      }

      return {
        init: init,
        dispose: dispose,
        change_active_append_itemable: change_active_append_itemable,
        add_append_itemable: add_append_itemable,
        remove_append_itemable: remove_append_itemable,
        can_append_itemables: can_append_itemables,
        confirm_append_itemables: confirm_append_itemables,
        change_append_itemable_note: change_append_itemable_note,
        batch_change_append_itemable_note: batch_change_append_itemable_note,
        change_append_itemable_gift: change_append_itemable_gift,
        clear_append_itemables: clear_append_itemables,
        change_weight: change_weight,
        change_note: change_note,
        edit_line_item: edit_line_item
      }
    }])
