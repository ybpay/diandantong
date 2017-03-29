angular.module('ddt_app.filters.filter', [])
    .filter('unsafe', ['$sce', function ($sce) {
        return function (val) {
            return $sce.trustAsHtml(val);
        }
    }]).filter('moment', ['$filter', function ($filter) {
        return function (datetime_string) {
            var datetime = new Date(Date.parse(datetime_string))
            var today = new Date()
            var second_dis = Math.floor((today.getTime() - datetime.getTime()) / 1000)
            var minute_dis = Math.floor(second_dis / 60)
            var hour_dis = Math.floor(minute_dis / 60)
            var day_dis = Math.floor(hour_dis / 24)
            if (minute_dis == 0) {
                return "刚刚"
            } else if (minute_dis >= 1 && minute_dis <= 59) {
                return "" + minute_dis + "分钟前"
            } else if (hour_dis >= 1 && hour_dis <= 23) {
                return "" + hour_dis + "小时前"
            } else if (day_dis >= 1 && day_dis <= 7) {
                return "" + day_dis + "天前"
            } else {
                return $filter('date')(datetime, "yyyy-MM-dd")
            }
        }
    }]).filter('distance', function(){
        return function(distance){
            if(distance == undefined){
                return "距离未知";
            }else if(distance > 1000){
                return parseInt(distance/1000) + "千米";
            }else{
                return parseInt(distance)+'米';
            }
        }
    }).filter('range', function () {
        return function (input, total) {
            total = parseInt(total);
            for (var i = 0; i < total; i++) {
                input.push(i);
            }
            return input;
        };
    });
