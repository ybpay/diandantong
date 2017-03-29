WebposModules.add_service('discount_plan')
angular.module('webpos.services.discount_plan', []).
  factory('DiscountPlanService', ['$resource', function($resource){
    var DiscountPlan = $resource('/branches/:branch_id/discount_plans/:id/:action',{},{
      query: { method: 'get', cache: true, isArray: true }
    })

    function query(branch_id, success){
      DiscountPlan.query({branch_id: branch_id}, success)
    }

    return {
      query: query
    }
  }])
