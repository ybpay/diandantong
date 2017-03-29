Ddt.factory('OrderCommentService',
  ['$resource', 'DdtConst',
    function ($resource, DdtConst) {
      var OrderComment = $resource(DdtConst.baseUrl + '/branches/:branch_id/orders/:order_id/order_comment/:action',
        { format: 'json'},
        {});


      function create(branch_id, order_id, order_comment_params, success) {
        OrderComment.save({branch_id: branch_id, order_id: order_id}, {
          order_comment: order_comment_params
        }, success);
      };

      return {
        create: create
      };
  }]);
