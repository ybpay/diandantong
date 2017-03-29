Ddt.factory('VipInfoSettingService',
  ['DdtConst', '$resource',
    function (DdtConst, $resource) {
      var Setting = $resource(DdtConst.baseUrl + '/vip_info_setting', {format: 'json'}, {
        get: {method: 'GET', isArray: false, cache: true}
      });

      return Setting;

    }]
);
