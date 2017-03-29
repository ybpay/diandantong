WebposModules.add_service('statistic');
angular.module('webpos.services.statistic',[]).
  factory('StatisticService',["$resource", function($resource){
    var Statistic = $resource("/statistics/:action", {format: 'json'}, {
      product_sales: {method: 'get', params: {action: 'product_sales'}},
      order_quantity: {method: 'get', params: {action: 'order_quantity'}}
    });

    function product_sales(params, success){ Statistic.product_sales(params, success)}
    function order_quantity(params, success){ Statistic.order_quantity(params,success)}


    return {
      product_sales: product_sales,
      order_quantity: order_quantity
    }


  }]);