//= require_tree ./directives/
//= require_tree ./services/
var webposCommon = (function(){
  function permit_enter(window,toParams,$rootScope){
       var menu_url = window.location.pathname+window.location.hash;
       var branch_id = toParams.branch_id;
        if(!$rootScope.has_menu_url(menu_url)){
          $rootScope.go_path("/webpos#")
        }
  }
    return {
        permit_enter: permit_enter
    }
})();



