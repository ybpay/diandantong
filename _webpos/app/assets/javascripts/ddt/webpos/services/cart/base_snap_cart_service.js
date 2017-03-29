WebposModules.add_service('base_snap_cart')
angular.module('webpos.services.base_snap_cart', []).
  factory('BaseSnapCartService', [function(){
    /*
      snap_cart = {
        line_items: [
          {
            itemable_type:  itemable.itemable_type,
            itemable_id:    itemable.itemable_id,
            product_id:     itemable.product_id,
            stock_quantity: itemable.stock_quantity,
            quantity:       1,
            min_quantity_for_order: 1,
            price:          itemable.price,
            original_price: itemable.original_price,
            name:           itemable.name,
            note:           note
            gift:           gift
            gift_reason:    gift_reason
            is_by_weight:   is_by_weight
          }
        ]
        total:      sum(price)
        item_total: sum(original_price)
        item_count: sum(quantity)
      }
    */

   /*
    * options[is_separate]: store itemable in different line_item
    */
    function add_itemable(cart, itemable, success, options){
      var is_separate = false;
      if(options){
        is_separate = options.is_separate;
      }
      var not_find = true
      var current_item = undefined
      itemable.note = itemable.note || ""
      itemable.gift = !!itemable.gift
      var min_quantity_for_order = itemable.min_quantity_for_order || 1
      if(!is_separate){
        angular.forEach(cart.line_items, function(line_item){
          if(not_find && line_item.index == itemable.index){
            /* 找到 */
            line_item.quantity ++
            not_find = false
            current_item = line_item
          }
        });
      }
      if(not_find){
        var quantity = 1;
        carted_quantity = get_quantity_in_cart(cart, itemable)
        if(carted_quantity < min_quantity_for_order){
          quantity = min_quantity_for_order - carted_quantity
        }
        var line_item = {
          index:          (new Date().getTime() + Math.random()),
          itemable_type:  itemable.itemable_type,
          itemable_id:    itemable.itemable_id,
          product_id:     itemable.product_id,
          stock_quantity: itemable.stock_quantity,
          quantity:       quantity,
          min_quantity_for_order: min_quantity_for_order,
          price:          itemable.price,
          original_price: itemable.original_price,
          name:           itemable.name,
          note:           itemable.note,
          gift:           itemable.gift,
          gift_reason:    itemable.gift_reason,
          is_by_weight:   itemable.is_by_weight,
        }
        current_item = line_item
        cart.line_items.push(line_item)
      }
      total(cart)
      if(success){ success(cart, current_item) }
    }

    function remove_itemable(cart, itemable, success){
      var not_find = true;
      var need_adjust_index = false;
      itemable.note = itemable.note || ""
      itemable.gift = !!itemable.gift
      var min_quantity_for_order = itemable.min_quantity_for_order || 1
      angular.forEach(cart.line_items, function(line_item, idx){
        if(not_find && line_item.index == itemable.index){
          if(line_item.quantity > 0){
            carted_quantity = get_quantity_in_cart(cart, itemable)
            if(carted_quantity - 1 < min_quantity_for_order){
              need_adjust_index = true;
              // delete all itemables
              angular.forEach(cart.line_items, function(cart_item){
                if(cart_item.itemable_type == itemable.itemable_type
                  && cart_item.itemable_id == itemable.itemable_id){
                  cart_item.quantity = 0;
                }
              })
            }else{
              line_item.quantity --
              if(line_item.quantity == 0){
                need_adjust_index = true;
              }
            }
          }
          not_find = false
        }
      })
      cart.line_items = cart.line_items.filter(function(line_item){ return line_item.quantity > 0})
      if(need_adjust_index){
        cart.line_items = adjust_index(cart.line_items)
      }
      if(not_find){}
      total(cart)
      if(success){ success(cart) }
    }

    function adjust_index(line_items){
      angular.forEach(line_items, function(line_item, index){
        line_item.index = index;
      })
      return line_items;
    }

    function new_cart(){
      var cart = { line_items: []}
      total(cart)
      return cart
    }

    function change_note(cart, itemable, note, success){
      angular.forEach(cart.line_items, function(line_item){
        if( line_item.index == itemable.index){
          line_item.note = note
        }
      })
      if(success){ success(cart) }
    }

    function change_to_line_items_attributes(cart){
      var line_items_attributes = []
      angular.forEach(cart.line_items, function(line_item){
        line_items_attributes.push({
          id:             line_item.id,
          itemable_type:  line_item.itemable_type,
          itemable_id:    line_item.itemable_id,
          quantity:       line_item.quantity,
          note:           line_item.note,
          gift:           line_item.gift,
          gift_reason:    line_item.gift_reason,
        })
      })
      return line_items_attributes;
    }

    function update_itemable(cart, itemable, success){
      angular.forEach(cart.line_items, function(line_item, index){
        if(line_item.itemable_id == itemable.itemable_id){
          line_item.name = itemable.name
          line_item.price = itemable.price
          line_item.original_price = itemable.original_price
          if(itemable.quantity){
            line_item.quantity = itemable.quantity;
          }
          if(itemable.new_itemable_id){
            line_item.itemable_id = itemable.new_itemable_id;
          }
          if(itemable.weight){
            line_item.weight = itemable.weight
          }
        }
      });
      total(cart);
      if(success){ success(cart); }
    }

    function total(cart){
      var total = 0
      var item_total = 0
      var item_count = 0
      angular.forEach(cart.line_items, function(line_item){
        total += line_item.quantity * parseFloat(line_item.price)
        item_total += line_item.quantity * parseFloat(line_item.original_price)
        item_count += line_item.quantity
      })
      cart.total = total
      cart.item_total = item_total
      cart.item_count = item_count
      return total
    }

    function get_quantity_in_cart(cart, itemable){
      return get_quantity(cart.line_items, itemable)
    }

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

    return {
      change_note: change_note,
      add_itemable:add_itemable,
      update_itemable: update_itemable,
      remove_itemable:remove_itemable,
      new_cart: new_cart,
      change_to_line_items_attributes: change_to_line_items_attributes
    }
  }])
