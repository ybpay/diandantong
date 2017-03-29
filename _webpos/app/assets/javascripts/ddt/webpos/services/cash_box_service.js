WebposModules.add_service('cash_box_setting')
angular.module('webpos.services.cash_box_setting',[])
.factory('CashBoxSettingService', [function(){
  function getAutoOpen() {
    if (get_ddb_cache("auto_open_cashbox") == null) {
      set_ddb_cache("auto_open_cashbox", true)
    };
    return get_ddb_cache("auto_open_cashbox")
  }
  function setAutoOpen(option){
      set_ddb_cache("auto_open_cashbox", option)
  }
  return{
    getAutoOpen: getAutoOpen,
    setAutoOpen: setAutoOpen
  }
}])