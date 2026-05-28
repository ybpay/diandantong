//= require jquery.minicolors
//= require jquery.minicolors.simple_form
//= require metisMenu/jquery.metisMenu.js
//= require pace/pace.min.js
//= require peity/jquery.peity.min.js
//= require slimscroll/jquery.slimscroll.min.js
//= require ./inspinia.js

// ckeditor/init removed — replaced by ActionText + TipTap
//= require moment
//= require bootstrap-datetimepicker
//= require locales/bootstrap-datetimepicker.zh-CN
//= require jquery-fileupload
//= require private_pub_master
//= require china_city/jquery.china_city
//= require select2
//= require select2_locale_zh-CN
//= require dd-select2
//= require jquery.nestable
//= require jquery_nested_form
//= require jquery.tablesorter.min
//= require highcharts
//= require highcharts/modules/drilldown
//= require handlebar/handlebars
//= require ./thirdparty/dateFormat
//= require ./thirdparty/jquery.marquee.min
//= require ./thirdparty/pretty-data
//= require_tree ./backend


window.App = {
  imagePreview: function(el){
    var id = $(el).attr("id") + "_preview"
    if(el.files &&  el.files[0]){
      var reader = new FileReader()
      reader.onload = function(e){
        $("#"+id).attr('src',e.target.result).removeClass("hidden").hide().fadeIn()
      }
      reader.readAsDataURL(el.files[0])
    }
  },

  alert : function(msg,to){
    $(".app-alert").remove()
    var info = "<div class='alert alert-block alert-danger app-alert' data-dismiss='alert'><button class='close' data-dismiss='alert'>×</button>" + msg + "</div>"
    $(info).hide().prependTo(to).fadeIn()
  },

  info : function(msg,to){
    $(".app-info").remove()
    var info = "<div class='alert alert-block alert-success app-info' data-dismiss='alert'><button class='close' data-dismiss='alert'>×</button>" + msg + "</div>"
    $(info).hide().prependTo(to).fadeIn()
  }
}


// datatimepicker
$.fn.datetimepicker.defaults = {
    pickDate: true,
    pickTime: true,
    useMinutes: true,
    useSeconds: true,
    useCurrent: true,
    minuteStepping: 1,
    format: 'YYYY-MM-DD hh:mm:ss',
    minDate: '1/1/1900',
    maxDate: '1/1/2100',
    showToday: true,
    collapse: true,
    language: "zh-CN",
    defaultDate: "",
    disabledDates: false,
    enabledDates: false,
    icons:{
        time: 'fa fa-clock-o',
        date: 'fa fa-calendar',
        up: 'fa fa-chevron-up',
        down: 'fa fa-chevron-down'
    },
    useStrict: false,
    direction: "auto",
    sideBySide: false,
    daysOfWeekDisabled: false
}

// minicolors
$.minicolors.defaults = {
    animationSpeed: 50,
    animationEasing: 'swing',
    change: null,
    changeDelay: 0,
    control: 'wheel',
    defaultValue: '#ffffff',
    hide: null,
    hideSpeed: 100,
    inline: false,
    letterCase: 'lowercase',
    opacity: false,
    position: 'bottom left',
    show: null,
    showSpeed: 100,
    theme: 'bootstrap'
  };

// set bootbox default
bootbox.setDefaults({
  locale: "zh_CN",
  show: true,
  backdrop: true,
  closeButton: true,
  animate: true,
  className: "my-modal"
});

// jquery fileupload locales
window.locale = {
    "fileupload": {
        "errors": {
            "File is too big": "文件太大",
            "File is too small": "文件太小",
            "Filetype not allowed": "文件格式不符合要求",
            "Maximum number of files exceeded": "超出文件最大数量",
            "uploadedBytes": "上传字节数超过文件大小",
            "Empty file upload result": "空"
        },
        "error": "错误",
        "start": "开始",
        "cancel": "取消",
        "destroy": "删除"
    }
};

Highcharts.setOptions({
  lang: {
    drillUpText: '◁ 返回'
  }
});

$(document).on("ajax:replace", init_nestable)
function init_nestable(){
  $('.dd-handle a').on('mousedown', function(e){
    e.stopPropagation();
  });
}

$(function(){
  $('[data-rel=tooltip]').tooltip();
  $('[data-rel=popover]').popover({html:true});
  init_nestable()
})

// advanced options
$(function(){
  $('.advanced-options-open').on('click', function(){
    $(this).hide()
    var parent = $(this).parent()
    $('.advanced-options-content',parent).slideDown('fast', function(){
      $('.advanced-options-close', parent).show()
    })

  })
  $('.advanced-options-close').on('click', function(){
    $(this).hide()
    var parent = $(this).parent()
    $('.advanced-options-content',parent).slideUp('fast', function(){
      $('.advanced-options-open', parent).show()
    })
  })
})


// sale info
$(function(){
  $.each(['sale_info', 'agent_info'], function(index, name){
    window['show_'+name] = function(){
      var class_name = name.replace('_', '-');
      $("."+class_name+" .qq-icon").hide()
      $("."+class_name+" .detail-info").removeClass("disabled")
    }
  })

  $.each(['sale_info', 'agent_info'], function(index, name){
    window['hide_'+name] = function(){
      var class_name = name.replace('_', '-');
      $("."+class_name+" .detail-info").addClass("disabled")
      setTimeout(function() {
        $("."+class_name+" .qq-icon").show()
      }, 300);
    }
  })
})

// change remote method
$(function(){
  $("a[data-remote][data-method=put]").attr("data-params", '{"_method":"put"}')
  $("a[data-remote][data-method=put]").attr("data-method", "post")
  $("a[data-remote][data-method=delete]").attr("data-params", '{"_method":"delete"}')
  $("a[data-remote][data-method=delete]").attr("data-method", "post")
})

function toggle_chart_expand(target){
  var box = $(target).parents(".widget-box")
  box.parent().toggleClass("full-screen-chart")
  var width, height;
  if($('.full-screen-chart').length > 0){
    width = box.width() - 40
    height = box.height() - 80
  }else{
    width = box.width() - 24
    height = 250
  }
  $(target).highcharts().setSize(width, height, true)
}

function animation_hover(){
  $('.contact-box').each(function () {
    animationHover(this, 'pulse');
  });
}

$(document).on('page:update', function(){
  animation_hover();
  $(".sortable-table").each(function(){
    $(this).tablesorter();
  })
});

// remember scroll
$(function() {
   $(window).unload(function() {
      var scrollPosition = $("body").scrollTop();
      localStorage.setItem("scrollPosition", scrollPosition);
   });
   if(localStorage.scrollPosition) {
      $("body").scrollTop(localStorage.getItem("scrollPosition"));
   }
});
