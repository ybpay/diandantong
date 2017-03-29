WebposModules.add_service('reservation_date')
angular.module('webpos.services.reservation_date', []).
  factory('ReservationDateService', [function () {
    function get(days, begin){
      var nag_labels = ['今天', '昨天', '前天']
      var pos_labels = ['今天', '明天', '后天']
      var dates = []
      
      var i = 0;
      if(begin){i=begin}
      for(; i < days; i++){
        var date = new Date()
        date.setDate(date.getDate() + i)
        var date_hash = {
          position: i,
          value: date,
          date_str: format(date, "yyyy-MM-dd")
        }
        var absi = Math.abs(i)
        if(absi <= 2){
          date_hash['first_label'] = i < 0 ? nag_labels[absi] : pos_labels[absi];
        }else{
          date_hash['first_label'] = format(date, 'MM-dd')
        }

        if(i <= 2){
          date_hash['second_label'] = format(date, 'MM-dd') + get_label_in_week(date)
        }else{
          date_hash['second_label'] = get_label_in_week(date)
        }
        dates.push(date_hash)
      }
      return dates
    }

    function get_label_in_week(date){
      var labels = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
      return labels[date.getDay()]
    }

    // format(new Date(), "yyyy-MM-dd hh:mm:ss.S") ==> 2006-07-02 08:09:04.423
    // format(new Date(), "yyyy-M-d h:m:s.S")      ==> 2006-7-2 8:9:4.18
    function format(date, fmt) {
      var o = {
        "M+": date.getMonth() + 1, //月份
        "d+": date.getDate(), //日
        "h+": date.getHours(), //小时
        "m+": date.getMinutes(), //分
        "s+": date.getSeconds(), //秒
        "q+": Math.floor((date.getMonth() + 3) / 3), //季度
        "S": date.getMilliseconds() //毫秒
      };
      if (/(y+)/.test(fmt)) fmt = fmt.replace(RegExp.$1, (date.getFullYear() + "").substr(4 - RegExp.$1.length));
      for (var k in o)
      if (new RegExp("(" + k + ")").test(fmt)) fmt = fmt.replace(RegExp.$1, (RegExp.$1.length == 1) ? (o[k]) : (("00" + o[k]).substr(("" + o[k]).length)));
      return fmt;
    }

    return {
      get: get
    }
}]);
