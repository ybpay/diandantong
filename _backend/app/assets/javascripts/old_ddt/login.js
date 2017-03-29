//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require js/bootbox.min
//= require js/jquery-ui-1.10.3.full.min

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


// set bootbox default
bootbox.setDefaults({
  locale: "zh_CN",
  show: true,
  backdrop: true,
  closeButton: true,
  animate: true,
  className: "my-modal"
});


$(function(){
  $('[data-rel=tooltip]').tooltip();
  $('[data-rel=popover]').popover({html:true});
})


// change remote method
$(function(){
  $("a[data-remote][data-method=put]").attr("data-params", '{"_method":"put"}')
  $("a[data-remote][data-method=put]").attr("data-method", "post")
  $("a[data-remote][data-method=delete]").attr("data-params", '{"_method":"delete"}')
  $("a[data-remote][data-method=delete]").attr("data-method", "post")
})

