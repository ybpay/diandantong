Ddt.factory('CensorReportService', ['$resource', '$location', 'DdtConst',
  function($resource, $location, DdtConst){
    var res = $resource(DdtConst.baseUrl + '/censor_reports', {format: 'json'}, {})
    return {
      report: function(title, desc, success) {
        res.save({
        }, {
          censor_report: {
            title: title,
            desc: desc
          }
        }, success);
      }
    }
}]);

