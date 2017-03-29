WebposModules.add_service('line_item')
angular.module('webpos.services.line_item',[]).
  factory('LineItemService',['$resource', function($resource){
    var LineItem = $resource('/branches/:branch_id/orders/:order_id/line_items/:id/:action',{},{
      change_price: { method: "post", params: {action: "change_price"}},
    })

    function change_price(branch_id, order_id, line_item_id, new_price, success){
      LineItem.change_price({branch_id: branch_id, order_id: order_id, id: line_item_id}, { new_price: new_price }, success);
    }

    return{
      change_price: change_price
    }
  }])