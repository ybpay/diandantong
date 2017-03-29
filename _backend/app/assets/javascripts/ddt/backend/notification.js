var notification_inited = false;
$(document).ready(function(){
  if(notification_inited){return;}
   notification_inited = true;
  window.init_notification = function(options){
    var current_account_id = options.current_account_id;
    var root_url = options.root_url;
    PrivatePub.subscribe("/messages/accounts/" + current_account_id, notifyNewMsg);

    var oldTitle = document.title;
    var interval = null;
    var isOldTitle = true;
    var newTitle = null;
    var link = null;

    var audios = {}
    $.each(['order_placed',
      'order_confirmed',
      'order_paid',
      'order_change_append_itemable',
      'order_change_delete_itemable',
      'order_hasten',
      'order_call_waiter'], function(index, type){
      audios[type] = {}
      audios[type]['mp3'] = root_url + 'audios/' + type + '.mp3'
      audios[type]['ogg'] = root_url + 'audios/' + type + '.ogg'
    })

    $("#clear_all_msgs_btn").on('click', function(){
      $('#msgs').html("");
      if(interval){ clearInterval(interval); }
      $(this).hide();
    })

    $(document).on('click','.msg',function(){
      $(this).fadeOut();
      $(this).remove();
      if($("#msgs").children().length == 0){
        $("#clear_all_msgs_btn").hide();
      }
    })

    function notifyNewMsg(data, channel) {
      if(data.msg == null){return;}
      newTitle = data.msg.title;
      content = data.msg.content;
      link = data.msg.link;

      var htmlCode = $('#template').html();
      htmlCode = htmlCode.replace(/@msg_title/, newTitle)
        .replace(/@msg_content/, content)
        .replace(/@msg_link/, link);
      $('#msgs').append(htmlCode);
      $('#clear_all_msgs_btn').show();
      if(interval){ clearInterval(interval); }
      interval = setInterval(changeTitle, 700);
      soundPlay(data.msg.type);
    }

    function changeTitle() {
      document.title = isOldTitle ? oldTitle : newTitle;
      isOldTitle = !isOldTitle;
    }

    var soundEmbed = null;
    //======================================================================
    function soundPlay(type) {
      var playTimes = 1;
      var audio = audios[type]
      if(!audio){
        console.warn("Cannot find this type("+type+") in audios.")
        return;
      }
      var ogg_url = audio['ogg']
      var mp3_url = audio['mp3']
      var media = null;
      try{
        media = new Audio(ogg_url);
      }catch(e){
        media = new Audio(mp3_url);
      }
      media.controls = "controls";
      var playAudio = function(){
        if(--playTimes==0){
          media.removeEventListener("ended",playAudio);
          return;
        }
        media.play();
      }
      media.addEventListener("ended",playAudio);
      var soundDiv = $("#sound");
      soundDiv.innerHTML = "";
      soundDiv.append(media);
      media.play();
    }

    $(window).focus(function () {
      clearInterval(interval);
      document.title = oldTitle;
    });
  };

  var options_elem = $("#init-notification-options");
  if (options_elem.length > 0){
    //var options = options_elem.data();
    var options = JSON.parse(options_elem.attr("data"));
    console.info(options);
    init_notification(options);
  }
});
