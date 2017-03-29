WebposModules.add_service('variant_package')
angular.module('webpos.services.variant_package', []).
  factory('VariantPackageService', ['$resource', function($resource){


    var VariantPackage = $resource('/branches/:branch_id/variant_packages/:id/:action',{},{
      create: { method: 'post'},
      update: { method: 'put'}
    })

    function create(branch_id, variant, weight, success){
      VariantPackage.create({branch_id: branch_id, variant_id: variant.id}, {weight: weight}, success);
    }

    function update(branch_id, params, success){
      VariantPackage.update({branch_id: branch_id, id: params.id}, {variant_id: params.variant_id, weight: params.weight}, success)
    }

    return {
      create: create,
      update: update
    }
  }])
