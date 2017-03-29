angular.module("ddt_app.services.combo_package",[]).
  factory('ComboPackageService', ['$resource', 'DdtConst',
    function ($resource, DdtConst) {
      var ComboPackage = $resource(DdtConst.baseUrl + '/branches/:branch_id/combo_packages/:id/:action', { format: 'json' })

      function create( branch_id, combo_package_params, success ){
        ComboPackage.create({ branch_id: branch_id }, {
          combo_package: combo_packgae_params
        }, success)
      }

    return {
      create: create
    }
  }]);