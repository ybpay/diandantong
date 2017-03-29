Ddt.
  factory('WechatShareRecordService', ['$rootScope' , '$resource', 'DdtConst',
    function ($rootScope, $resource, DdtConst) {
    var WechatShareRecord = $resource(DdtConst.baseUrl + '/wechat_share_records/:id/:action', { format: 'json' },{
      confirm: { method: 'post' , params: {action: 'confirm'}}
    });

    function update(share_info, success){
      success = success || function(){};
      share_info.img_url = share_info.imgUrl;
      WechatShareRecord.confirm(
        {
          id: share_info.id
        },
        {
          wechat_share_record: share_info
        },
        success
      );
    }

    function get(id, success){
      WechatShareRecord.get({id: id}, success)
    }

    function query(params, success){
      WechatShareRecord.query(params, success)
    }

    function create_id(trigger_timestamp, success){
      WechatShareRecord.save({trigger_timestamp: trigger_timestamp}, success)
    }

    return {
      update: update,
      create_id: create_id,
      get: get,
      query: query
    }

  }]);
