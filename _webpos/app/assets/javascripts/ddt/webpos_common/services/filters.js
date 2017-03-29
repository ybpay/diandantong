WebposModules.add_service('filters')
angular.module('webpos.services.filters', [])
.filter('cut', function () {
    return function (value, wordwise, max, tail) {
        if (!value) return '';

        max = parseInt(max, 10);
        if (!max) return value;
        if (value.length <= max) return value;

        value = value.substr(0, max);
        if (wordwise) {
            var lastspace = value.lastIndexOf(' ');
            if (lastspace != -1) {
                value = value.substr(0, lastspace);
            }
        }

        return value + (tail || ' …');
    };
}).filter('unsafe', ['$sce', function($sce) {
    return function(val) {
        return $sce.trustAsHtml(val);
    }
}]).filter('password', [function() {
return function(str) {
    if (!str) return '';
    var result = ''
    for(i=0; i < str.length; i++){
        result += '*'
    }
    return result
}
}]).filter('reverse', function() {
  return function(items) {
    if(items){
        return items.slice().reverse();
    }else{
        return []
    }
  };
});