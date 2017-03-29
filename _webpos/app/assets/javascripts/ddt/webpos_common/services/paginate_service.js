WebposModules.add_service('paginate')
angular.module('webpos.services.paginate', []).
  factory('PaginateService', [function(){
    /* useage
     * var Order = PaginateService.init(OrderService, { branch_id: $scope.branch_id }, function(orders){ $scope.orders = orders })
     * Order.query()
     * Order.set_page(5).query()
     * Order.next_page().query()
     * Order.previous_page().query()
     */

    function init(resource, default_params, success){
      return (function(){
        var params = {}
        var max_page = null
        $.extend(params, default_params)
        params.page = params.page || 1
        params.per_page = params.per_page || 10
        var initing = true
        var querying = false
        function is_initing(){ return initing }
        function is_querying(){ return querying }
        function query(){
          querying = true
          initing = false
          if(typeof resource === "function"){
            resource(params, function(data){
              if(data.length < params.per_page){
                max_page = params.page
              }
              querying = false
              if(success){ success(data) }
            })
          }else{
            resource.query(params, function(data){
              if(data.length < params.per_page){
                max_page = params.page
              }
              querying = false
              if(success){ success(data) }
            })
          }
        }

        function current_page(){
          return params.page
        }

        function set_page(page){
          params.page = page
          if(params.page <= 0){ params.page = 1 }
          if(max_page && params.page > max_page){ params.page = max_page }
          return result
        }

        function next_page(){
          return set_page(params.page + 1);
        }

        function previous_page(){
          return set_page(params.page - 1);
        }

        function current_index(){
          return (params.page - 1) * params.per_page
        }

        function is_last_page(){
          return max_page && params.page === max_page
        }

        var result = {
          is_querying: is_querying,
          is_initing: is_initing,
          query: query,
          current_page: current_page,
          is_last_page: is_last_page,
          set_page: set_page,
          next_page: next_page,
          previous_page: previous_page,
          current_index: current_index
        }

        return result;
      })();
    }

    return {
      init: init
    }
  }])