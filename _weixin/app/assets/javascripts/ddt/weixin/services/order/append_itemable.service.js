Ddt.factory('AppendItemableService',
  ['$rootScope','BaseOrderService', function ($rootScope, BaseOrderService) {
    /*
      {
        total: 222,
        item_count: 2,
        line_items: [
          { quantity: 1, itemable_type: "Ddt::Variant", itemable_id: 200, ..., note: '品注'},
          { quantity: 1, itemable_type: "Ddt::ComboPackage",
            combo_package: {
              name: "[两素]白菜*1 茄子*1",
              price: 10,
              combo_id: 5,
              items: [
                {combo_item_id: 8, variant_id: 200, quantity: 1 },
                {combo_item_id: 9, variant_id: 201, quantity: 2 },
                {combo_item_id: 9, variant_id: 202, quantity: 1 }
              ]
            }
          }
        ]
      }
    */
    var cart = null;
    var order = null;

    function get_cart(){ return cart }
    function init(_order){
      order = _order;
      if(cart == null){
        cart = {
          total: 0,
          item_count: 0,
          line_items: []
        }
      }
    }

    // 套餐选择页面调用该方法添加套餐
    function add_combo_package(combo_package){
      var index = -1;
      angular.forEach(cart.line_items, function(line_item, idx){
        if(line_item.itemable_type == 'Ddt::ComboPackage'){
          if(same_combo_package(line_item.combo_package, combo_package)){ index = idx}
        }
      })
      if(index == -1){
        cart.line_items.push({
          quantity: 1,
          itemable_type: "Ddt::ComboPackage",
          itemable_id: combo_package.id,
          name: combo_package.name,
          note: "",
          price: combo_package.price,
          combo_package: combo_package
        })
      }else{
        cart.line_items[index].quantity += 1;
      }
      total(cart);
    }

    function get_ordered_quantity(itemable){
      return get_quantity(order.line_items, itemable)
    }

    function get_appended_quantity(itemable){
      return get_quantity(cart.line_items, itemable)
    }

    function get_quantity(collection, itemable){
      var quantity = 0
      angular.forEach(collection, function(line_item){
        if(line_item.itemable_type == itemable.itemable_type
          && line_item.itemable_id == itemable.itemable_id){
          quantity += line_item.quantity
          return;
        }
      })
      return quantity;
    }

    function delete_itemables(itemable){
      var result = []
      angular.forEach(cart.line_items, function(line_item){
        if( !(line_item.itemable_type == itemable.itemable_type
            && line_item.itemable_id == itemable.itemable_id) ){
          result.push(line_item)
        }
      })
      cart.line_items = result;
    }


    function append_itemable(itemable, note, success){
      var not_find = true
      note = note || ""
      var min_quantity_for_order = itemable.min_quantity_for_order

      angular.forEach(cart.line_items, function(line_item){
        if(not_find && line_item.itemable_type == itemable.itemable_type
                    && line_item.itemable_id == itemable.itemable_id
                    && line_item.note == note){
          line_item.quantity ++
          not_find = false
        }
      })
      if(not_find){

        var quantity = 1;
        var ordered_quantity = get_ordered_quantity(itemable)
        /* 如果 ordered_quantity !=0 则说明这个产品已经在单里，已经过了 min_quantity_for_order 的检验*/
        if(ordered_quantity==0){
          var appended_quantity = get_appended_quantity(itemable)
          if(appended_quantity +1 < min_quantity_for_order){
            quantity = min_quantity_for_order - appended_quantity
          }else{
            quantity = 1
          }
        }

        var line_item = {
          itemable_type: itemable.itemable_type,
          itemable_id: itemable.itemable_id,
          stock_quantity: itemable.stock_quantity,
          quantity: quantity,
          price: itemable.price,
          name: itemable.name,
          note: note,
          category_ids: itemable.category_ids,
          min_quantity_for_order: min_quantity_for_order
        }
        cart.line_items.push(line_item)
      }
      total(cart);
      success(cart);
    }

    function remove_itemable(itemable, note, success){
      var not_find = true
      note = note || ""
      angular.forEach(cart.line_items, function(line_item){
        if(not_find && line_item.itemable_type == itemable.itemable_type
                    && line_item.itemable_id == itemable.itemable_id
                    && line_item.note == note){
          if(line_item.quantity > 0){
            line_item.quantity --
            not_find = false
          }
        }
      })
      if(not_find){
        angular.forEach(cart.line_items, function(line_item){
          if(not_find && line_item.itemable_type == itemable.itemable_type
                      && line_item.itemable_id == itemable.itemable_id){
            if(line_item.quantity > 0){
              line_item.quantity --
              not_find = false
            }
          }
        })
      }
      var min_quantity_for_order = itemable.min_quantity_for_order;
      var ordered_quantity = get_ordered_quantity(itemable)
      var appended_quantity = get_appended_quantity(itemable)
      if(ordered_quantity + appended_quantity< min_quantity_for_order){
        delete_itemables(itemable)
      }
      cart.line_items = cart.line_items.filter(function(line_item){
        return line_item.quantity > 0;
      })
      total(cart);
      success(cart);
    }

    function submit(branch_id, order_type, order_id, success){
      var itemables = []
      angular.forEach(cart.line_items, function(itemable){
        itemables.push({
          quantity: itemable.quantity,
          itemable_type: itemable.itemable_type,
          itemable_id: itemable.itemable_id,
          note: itemable.note
        })
      })
      BaseOrderService.append_itemables(order_type, branch_id, order_id, itemables, function(){
        // clear cart
        cart = {
          total: 0,
          item_count: 0,
          line_items: []
        };
        console.log(cart)
        success();
      })
    }

    function total(cart){
      var total = 0
      var item_count = 0
      angular.forEach(cart.line_items, function(line_item){
        total += line_item.quantity * parseFloat(line_item.price)
        item_count += line_item.quantity
      })
      cart.total = total
      cart.item_count = item_count
      return total
    }

    function same_combo_package(combo_package1, combo_package2){
      if(combo_package1.combo_id != combo_package2.combo_id){return false}
      var items1 = combo_package1.items.sort()
      var items2 = combo_package2.items.sort()
      var same = true;
      angular.forEach(items1, function(item1, index){
        var item2 = items2[index];
        if(item1.combo_item_id != item2.combo_item_id){ same = false}
        if(item1.variant_id != item2.variant_id){ same = false}
        if(item1.quantity != item2.quantity){ same = false}
      })
      return same;
    }



    return {
      init: init,
      get_cart: get_cart,
      submit: submit,
      add_combo_package: add_combo_package,
      append_itemable: append_itemable,
      remove_itemable: remove_itemable
    }
  }]);
