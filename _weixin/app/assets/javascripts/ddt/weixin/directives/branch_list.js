Ddt.module('ddt_app.directives.branch_list', [])
.directive('branchList', ['$location', '$rootScope',
  function ($location, $rootScope) {
  return {
    restrict: 'EA',
    scope: {
      branch_index_layout: '=ngBranchIndexLayout',
      branches: '=ngBranches'
    },
    replace: true,
    templateUrl: '/weixin/client_partials/main/branches/list.html' + version_timestamp,
    link: function(scope, elements, attrs){
      scope.go_page = $rootScope.go_page;
    	scope.getArray = function(n){
    		var result = [];
    		for(var i = 0; i < Math.ceil(n) ; i ++ ){
    			result.push(i);
    		}
    		return result;
    	}
    }
  }
}]);
