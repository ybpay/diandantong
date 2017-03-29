Ddt.factory('DeliverymanOrdersService',
  ['$resource', 'DdtConst',
  function($resource, DdtConst){
    var Order = $resource(DdtConst.baseUrl + '/deliveryman_orders',{ format: 'json' },{
      query: {method: 'get', params: {}, isArray: true}
    });

    var orders = [];

    function query(options, cb){
      params = {}
      if(options.assign){
        params['assign'] = true
      }
      Order.query(params, function(orders){
        orders = orders
        cb(orders)
      })
    }

    return {
      query: query
    }
  }]);
