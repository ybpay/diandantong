WebposModules.add_service('form_element')
angular.module('webpos.services.form_element', []).
  factory('FormElementService', ['$resource', function($resource){
    var FormElement = $resource('/branches/:branch_id/form_elements/:id/:action',{},{
      query: { method: 'get', isArray: true, cache: true }
    })

    function query(branch_id, success){
      FormElement.query({branch_id: branch_id}, success)
    }

    return {
      query: query
    }
  }])