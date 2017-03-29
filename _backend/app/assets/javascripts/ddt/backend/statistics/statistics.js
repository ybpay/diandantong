if (window.location.pathname.indexOf('_statistics/') >= 0){

  function replaceQueryParam(param, newval, search) {
    var regex = new RegExp("([?;&])" + param + "[^&;]*[;&]?");
    var query = search.replace(regex, "$1").replace(/&$/, '');
    return (query.length > 2 ? query + "&" : "?") + (newval ? param + "=" + newval : '');
  }

  function query_cache_state(){
    var pathname = window.location.pathname
    if (pathname.lastIndexOf('.html') != -1){
      pathname = pathname.replace('.html', '.json')
    } else {
      pathname += '.json'
    }
    var search = window.location.search
    var url = pathname  + search
    $.ajax({
      url: url,
      dataType: 'text',
      success: function(state){
        switch(state){
          case 'commit':
            break;
          case 'completed':
            window.location.reload();
            break;
          case 'exception': {
            window.location.reload();  // 优化后可以显示结果/csv/xls
            break;
          }
          default: {
            console.error("illegal state");
          }
        }
      }
    })
  }
}