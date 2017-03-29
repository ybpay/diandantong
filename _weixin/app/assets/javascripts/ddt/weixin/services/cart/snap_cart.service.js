Ddt.module('ddt_app.services.snap_cart', []).
factory('SnapCartService',
  ['BaseCartService',
    function (BaseCartService) {
      var snap_carts = {};
      snap_carts.delivery = [];
      snap_carts.reservation = [];
      snap_carts.eat_in_hall = [];
      snap_carts.fastfood = [];
      snap_carts.groupon = [];
      snap_carts.recharge = [];
      snap_carts.payment = [];

      function get_carts(cart_type){
        var carts;
        switch(cart_type){
          case 'delivery':     carts = snap_carts.delivery; break;
          case 'reservation':  carts = snap_carts.reservation; break;
          case 'eat_in_hall':  carts = snap_carts.eat_in_hall; break;
          case 'fastfood':     carts = snap_carts.fastfood; break;
          case 'groupon':      carts = snap_carts.groupon; break;
          case 'recharge':     carts = snap_carts.recharge; break;
          case 'payment':      carts = snap_carts.payment; break;
        }
        return carts;
      }

      function set_cart(cart_type, branch_id, cart){
        get_carts(cart_type)[branch_id] = cart
      }

      function get(cart_type, branch_id, success){
        var snap_cart = get_carts(cart_type)[branch_id]
        if(snap_cart){
          if(success){ success(snap_cart) }
        }else{
          BaseCartService.get(cart_type, branch_id, function(cart){
            snap_cart = cart
            total(snap_cart)
            set_cart(cart_type, branch_id, snap_cart)
            if(success){ success(snap_cart) }
          })
        }
      }

      function get_carted_quantity(cart, itemable){
        var sum = 0
        angular.forEach(cart.line_items, function(line_item){
          if(line_item.itemable_type == itemable.itemable_type
             && line_item.itemable_id == itemable.itemable_id){
            sum += line_item.quantity
          }
        })
        return sum;
      }

      function delete_itemables(cart, itemable){
        var result = [];
        angular.forEach(cart.line_items, function(line_item){
          if(!(line_item.itemable_type == itemable.itemable_type
               && line_item.itemable_id == itemable.itemable_id) ){
            result.push(line_item)
          }
        })
        cart.line_items = result;
        return cart;
      }

      function add_itemable(cart_type, branch_id, itemable, success){
        get(cart_type, branch_id, function(snap_cart){
          itemable.note = itemable.note || ""
          var not_find = true
          var min_quantity_for_order = itemable.min_quantity_for_order || 1
          angular.forEach(snap_cart.line_items, function(line_item){
            if(not_find && line_item.itemable_type == itemable.itemable_type && line_item.itemable_id == itemable.itemable_id && line_item.note == itemable.note){
              line_item.quantity ++
              not_find = false
            }
          })
          if(not_find){
            var quantity = 1;
            var carted_quantity = get_carted_quantity(snap_cart, itemable)
            if(carted_quantity == 0){
              quantity = min_quantity_for_order
            }

            var line_item = {
              itemable_type: itemable.itemable_type,
              itemable_id: itemable.itemable_id,
              stock_quantity: itemable.stock_quantity,
              quantity: quantity,
              min_quantity_for_order: min_quantity_for_order,
              price: itemable.price,
              name: itemable.name,
              note: itemable.note,
              category_ids: itemable.category_ids
            }
            if(itemable.original_price){
              line_item.original_price = itemable.original_price;
            }
            snap_cart.line_items.push(line_item)
          }
          total(snap_cart)
          if(success){ success(snap_cart) }
        })
      }

      function remove_itemable(cart_type, branch_id, itemable, success){
        get(cart_type, branch_id, function(snap_cart){
          var not_find = true
          itemable.note = itemable.note || "";
          angular.forEach(snap_cart.line_items, function(line_item){
            if(not_find && line_item.itemable_type == itemable.itemable_type && line_item.itemable_id == itemable.itemable_id && line_item.note == itemable.note ){
              if(line_item.quantity > 0){
                line_item.quantity --
                not_find = false
              }
            }
          })
          if(not_find){
            angular.forEach(snap_cart.line_items, function(line_item){
              if(not_find && line_item.itemable_type == itemable.itemable_type && line_item.itemable_id == itemable.itemable_id){
                if(line_item.quantity > 0){
                  line_item.quantity --
                  not_find = false
                }
              }
            })
          }
          var min_quantity_for_order = itemable.min_quantity_for_order;
          var carted_quantity = get_carted_quantity(snap_cart, itemable)
          if(carted_quantity < min_quantity_for_order){
            snap_cart = delete_itemables(snap_cart, itemable)
          }
          total(snap_cart)
          if(success){ success(snap_cart) }
        })
      }

      function clear(cart_type, branch_id, success){
        get(cart_type, branch_id, function(snap_cart){
          angular.forEach(snap_cart.line_items, function(line_item){
            line_item.quantity = 0
          })
          total(snap_cart)
          if(success){ success(snap_cart) }
        })
      }

      function update_cart(cart_type, branch_id, success){
        get(cart_type, branch_id, function(snap_cart){
          BaseCartService.update_cart(cart_type, branch_id, {
            line_items_attributes: change_to_line_items_attributes(snap_cart)
          }, function(cart){
            set_cart(cart_type, branch_id, cart)
            if(success){ success(cart) }
          })
        })
      }

      function change_to_line_items_attributes(snap_cart){
        var line_items_attributes = []
        angular.forEach(snap_cart.line_items, function(line_item){
          line_items_attributes.push({
            id:             line_item.id,
            itemable_type:  line_item.itemable_type,
            itemable_id:    line_item.itemable_id,
            quantity:       line_item.quantity,
            note:           line_item.note
          })
        })
        return line_items_attributes;
      }

      function total(snap_cart){
        var total = 0
        var item_total = 0
        var item_count = 0
        angular.forEach(snap_cart.line_items, function(line_item){
          total += line_item.quantity * parseFloat(line_item.price)
          item_total += line_item.quantity * parseFloat(line_item.original_price)
          item_count += line_item.quantity
        })
        snap_cart.total = total
        snap_cart.item_total = item_total
        snap_cart.item_count = item_count
        return total
      }

      function destroy(cart_type, branch_id){
        get_carts(cart_type)[branch_id] = null
      }

      return {
        get: get,
        set_cart: set_cart,
        add_itemable: add_itemable,
        remove_itemable: remove_itemable,
        clear: clear,
        destroy: destroy,
        update_cart: update_cart
      }
  }]);
