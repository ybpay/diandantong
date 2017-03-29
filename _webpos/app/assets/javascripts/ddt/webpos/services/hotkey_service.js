WebposModules.add_service('hotkey')
angular.module('webpos.services.hotkey', [])
.service('HotkeyService',
  [function(){

    /*'←', '↑', '→', '↓', '*',*/
    var keys = ['F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12', '+', '-']

    var settings = [
      {select_options: keys, name: '加菜', index: 'append_itemable'},
      {select_options: keys, name: '退菜', index: 'subtract_itemable'},
      {select_options: keys, name: '会员识别', index: 'hysb'},
      {select_options: keys, name: '优惠券', index: 'yhq'},
      {select_options: keys, name: '权限打折', index: 'qxdz'},
      {select_options: keys, name: '权限减免', index: 'qxjm'},
      {select_options: keys, name: '折扣方案', index: 'discount_plan'},
      {select_options: keys, name: '拉划菜单', index: 'print_product_bill'},
      {select_options: keys, name: '拉消费单', index: 'print_consume_bill'},
      {select_options: keys, name: '抹零', index: 'moling'},
    ]

    var default_hotkeys = {
      append_itemable: '+',
      subtract_itemable: '-',
      hysb: 'F5',
      yhq:  'F6',
      qxdz: 'F7',
      qxjm: 'F8',
      discount_plan: 'F9',
      print_product_bill: 'F10',
      print_consume_bill: 'F11',
      moling: 'F12',
      settings: settings
    }

    var hotkeys = null;
    function set(index, key){
      if(hotkeys){
        hotkeys[index] = key
      }else{
        hotkeys = get()
        hotkeys[index] = key
      }
      set_ddb_cache('hotkeys', hotkeys)
    }

    function get(){
      var hk = get_ddb_cache('hotkeys')
      if(hk){
        return hk
      }else{
        hk = default_hotkeys;
        set_ddb_cache('hotkeys', hk)
        return hk
      }
    }

    function get_key(index){
      return get()[index]
    }

    function is_conflict(){
      return false
    }

    return {
      get: get,
      set: set,
      get_key: get_key,
      is_conflict: is_conflict
    }
  }])
