WebposModules.add_service('shipment')
angular.module('webpos.services.shipment', []).
  factory('ShipmentService', ['$resource', function($resource){


    var DeliveryMan  = $resource('/branches/:branch_id/delivery_mans/:id/:action',{},{})
    var DeliveryZone = $resource('/branches/:branch_id/delivery_zones/:id/:action',{},{})
    var DeliveryDate = $resource('/branches/:branch_id/delivery_dates/:id/:action',{},{})

    var resources = {
      'delivery_mans' : DeliveryMan,
      'delivery_zones': DeliveryZone,
      'delivery_dates': DeliveryDate
    }

    function query(key, branch_id, success){
      resources[key].query({branch_id: branch_id}, success)
    }

    return {
      query: query
    }
  }])