document.write("<div id='compatibility_alert' class='alert alert-danger alert-dismissable' style='margin:0;'><button type='button' class='close' data-dismiss='alert' aria-hidden='true'>&times;</button><center>您使用的浏览器不支持最新的国际标准，为了保证良好的操作体验，强烈推荐您下载使用<a href='http://www.google.cn/intl/zh-CN/chrome/' target='_blank'>谷歌浏览器</a>或<a href='http://www.firefox.com.cn/download/' target='_blank'>火狐浏览器</a>，速度更快！</center></div>");
document.ready = function(){
  setTimeout(function(){$("#compatibility_alert").slideUp()}, 6000);
}
