Ddt.module('ddt_app.services.promotion', []).
  factory('PromotionService', ['$rootScope' , '$resource', 'DdtConst',
    function ($rootScope, $resource, DdtConst) {
    var Promotion = $resource(DdtConst.baseUrl + '/promotions/:id/:action', { format: 'json'}, {
      query: {method: 'GET', isArray: true, cache: true}
    })

    function query(success){
      Promotion.query({}, success)
    }

    function show_on_index(success){
      success($rootScope.current_shop.promotions_show_on_index)
    }

    function get(promotion_id, success){
      Promotion.get({id: promotion_id}, success)
    }

    return {
      query:query,
      show_on_index: show_on_index,
      get:get
    }
  }]);
