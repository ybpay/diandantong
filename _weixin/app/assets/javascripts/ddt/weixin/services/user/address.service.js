Ddt.factory('AddressService',
  ['$rootScope', '$resource', 'DdtConst',
    function ($rootScope, $resource, DdtConst) {
      var Address = $resource(DdtConst.baseUrl + '/user/addresses/:id/:action', { format: 'json' }, {
        update: { method: 'post', params: { action: 'patch' }},
        set_default: { method: 'post', params: { action: 'set_default' }, isArray: true},
        destroy: { method: 'post', params: { action: 'delete' }}
      })

      var urls = []
      var address = null;
      var map_type = null;

      //存储一个url
      function store_url(url){
        urls.push(url);
      }

      //取出url
      function restore_url(){
        if(urls.length == 0){ return null; }
        return urls.pop();
      }

      //存储地址
      function store_address(addr){
        address = addr;
      }

      //清空存储地址
      function delete_store_address(){
        address = null;
      }

      function restore_address(){
        if(address == null){
          return { name: '', phone: '', building: '', room_no: '', city_name: '', latitude: null, longitude: null };
        }
        return address;
      }

      function query(success){
        Address.query({}, success)
      }

      function create(address_params, success){
        Address.save({}, {
          address: address_params
        }, success)
      }

      function update(address_id, address_params, success){
        Address.update({ id: address_id }, {
          address: address_params
        }, success)
      }

      function get(address_id, success){
        Address.get({id: address_id}, success);
      }

      function destroy(address_id, success){
        Address.destroy({ id: address_id }, {}, success)
      }

      function set_default(address_id, success){
        Address.set_default({ id: address_id }, {} ,success)
      }

    return {
      query:query,
      create:create,
      update:update,
      destroy:destroy,
      set_default: set_default,
      restore_url: restore_url,
      store_url: store_url,
      restore_address: restore_address,
      store_address: store_address,
      delete_store_address: delete_store_address,
      get: get
    }
  }]);
