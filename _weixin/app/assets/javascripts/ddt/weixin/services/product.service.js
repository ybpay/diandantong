Ddt.module('ddt_app.services.product', []).
  factory('ProductService', ['$rootScope' , '$resource', 'DdtConst',
    function ($rootScope, $resource, DdtConst) {

    var timestamp = null;

    function reset_timestamp(){
      timestamp = Date.now().toString()
    }
    reset_timestamp();

    var Product = $resource(DdtConst.baseUrl + '/branches/:branch_id/products/:id/:action', { format: 'json' },{
      query: {method: 'GET', isArray: true, cache: true},
      get: {method: 'GET', cache: true}
    });



    function query(query_params, success){
      $.extend(query_params, {t: timestamp})
      Product.query(query_params, function(products){
        angular.forEach(products, function(product){
          var length = product.variants.length
          for(var i=0;i<length;i++){
            product.variants[i].price = product.variant_infos.prices[i]
            product.variants[i].stock_quantity = product.variant_infos.stock_quantitys[i]
            product.variants[i].sale_quantity = product.variant_infos.sale_quantitys[i]
            product.variants[i].line_items = [];
            product.variants[i].item_notes = product.item_notes
          }
        })
        if(success){ success(products)}
      })
    }

    function get(branch_id, product_id, success){
      Product.get($.extend({ branch_id: branch_id, id: product_id }, {t: timestamp}), success)
    }

    function expire_cache(){
      reset_timestamp();
    }

    return {
      query: query,
      get: get,
      expire_cache: expire_cache
    }
  }]);
