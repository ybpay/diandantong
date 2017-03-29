WebposModules.add_service('estimate_clear')
angular.module('webpos.services.estimate_clear',[]).
  factory('EstimateClearService',['$resource', function($resource){
    var EstimateClear = $resource('/branches/:branch_id/estimate_clear/:action',
      {
        branch_id: '@branch_id',
      }, {
      query: {method: 'get', isArray: true, cache: false},
      add: {method: 'post', params: {action: 'add'}},
      remove: {method: 'post', params: {action: 'remove'}},
      clear: {method: 'post', params: {action: 'clear'}},
      add_reciprocal: {method: 'post', params: {action: 'add_reciprocal'}},
      remove_reciprocal: {method: 'post', params: {action: 'remove_reciprocal'}}
    });

    return {
      gets: function(branch_id, success){
        EstimateClear.query({branch_id: branch_id}, success);
      },

      add: function(branch_id, variant_id, success){
        EstimateClear.add({ branch_id: branch_id }, { variant_id: variant_id }, success);
      },

      remove: function(branch_id, variant_id, success){
        EstimateClear.remove({ branch_id: branch_id }, { variant_id: variant_id }, success);
      },

      clear: function(branch_id, success){
        EstimateClear.clear({ branch_id: branch_id }, success);
      },

      add_reciprocal: function(branch_id, variant_id, quantity, success){
        EstimateClear.add_reciprocal({ branch_id: branch_id }, { variant_id: variant_id, quantity: quantity }, success);
      },

      remove_reciprocal: function(branch_id, variant_id, success){
        EstimateClear.remove_reciprocal({ branch_id: branch_id }, { variant_id: variant_id }, success);
      }
    };
  }]);