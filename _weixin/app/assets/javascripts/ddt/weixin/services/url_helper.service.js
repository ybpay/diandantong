Ddt.module('ddt_app.services.url_helper', []).
  factory('UrlHelperService', ['$rootScope', 'BranchService', 'ProductService',
    function ($rootScope, BranchService, ProductService) {
      function go_show_product(product, cart_type){
        $rootScope.go('/branches/' + product.branch_id + '/products/' + product.id + '?cart_type=' + cart_type)
      }

      function go_search_product(branch_id, cart_type){
        $rootScope.go('/branches/' + branch_id + '/products/search?cart_type=' + cart_type)
      }

      function go_products_list(branch_id, cart_type){
        $rootScope.go('/branches/' + branch_id + '/products/' + cart_type)
      }

    return {
      go_show_product   : go_show_product,
      go_search_product : go_search_product,
      go_products_list  : go_products_list
    }
  }]);
