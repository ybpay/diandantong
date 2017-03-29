var version_timestamp = "?v" + ('development' != CrmConst.env ? "201610210932" : Date.parse(new Date()));
var ls_version = '201609270952'
var CrmModules = (function(){
  var services = []
  var controllers = []
  var directives = []
  var modules = []

  function add(module){ modules.push(module)}
  function add_service(service){ services.push(service)}
  function add_controller(controller){ controllers.push(controller) }
  function add_directive(directive){ directives.push(directive) }

  function get(others){
    var all = []
    services.forEach(function(service){ all.push("crm.services." + service) })
    controllers.forEach(function(controller){ all.push("crm.controllers." + controller) })
    directives.forEach(function(directive){ all.push("crm.directives." + directive) })
    modules.forEach(function(module){ all.push("crm." + module) })
    return all.concat(others)
  }

  return {
    add: add,
    add_service: add_service,
    add_controller: add_controller,
    add_directive: add_directive,
    get: get
  }
})();

var template_base_url = "/backend/crm/templates"
var template_url = function(url){
  return template_base_url + "" + url + "" + version_timestamp;
}
var mask_num = 0;
function showLoadingMask(){ mask_num++; $('#crm-loading').show(); }
function hideLoadingMask(){ if(mask_num > 0){ mask_num -- }; if(mask_num == 0){$('#crm-loading').hide();}}
function clearLoadingMask(){ mask_num=0; $('#crm-loading').hide();}

// mock for ngAria
console.realWarn = console.warn;
console.warn = function (message) {
    if (message.indexOf("ARIA") == -1) {
        console.realWarn.apply(console, arguments);
    }
};
