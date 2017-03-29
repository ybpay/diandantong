WebposModules.add_service('time_interval')
angular.module('webpos.services.time_interval', []).
  factory('TimeIntervalService', ['$resource', function($resource){
    var TimeInterval = $resource('/branches/:branch_id/time_intervals/:id/:action', {},{
    });

    function query(branch_id, success){
      TimeInterval.query({branch_id: branch_id}, function(time_intervals){
        success(time_intervals)
      })
    }

    return {
      query: query
    }
  }])
