Ddt.factory('OrderItemableService',
  ['DdtConst', '$resource',
    function (DdtConst, $resource) {
      var OrderItemable = $resource(DdtConst.baseUrl + '/branches/:branch_id/tables/:table_id/order_itemables/:id/:action', {format: 'json'}, {
        query: {method: 'GET', isArray: true, cache: false},
        plus: { method: 'POST', params: { action: 'plus' }},
        minus: { method: 'POST', params: { action: 'minus' }}
      });

      function query(branch_id, table_id, success){
        OrderItemable.query({ branch_id: branch_id, table_id: table_id}, success)
      }

      function plus(branch_id, table_id, id, success){
        OrderItemable.plus({ branch_id: branch_id, table_id: table_id, id: id}, {}, success)
      }

      function minus(branch_id, table_id, id, success){
        OrderItemable.minus({ branch_id: branch_id, table_id: table_id, id: id}, {}, success)
      }

      return {
        query: query,
        plus: plus,
        minus: minus
      }
    }]);
