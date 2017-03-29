$(document).ready(function() {
  $("#upload_vip_infos").dialog({
    autoOpen: false,
    width: 350
  });
  $("#upload_vip_info_requirment_modal").dialog({
    autoOpen: false,
    width: 600
  });
  $("#upload_vip_info_file").click(function(event) {
    event.preventDefault(event);
    $("#upload_vip_infos").dialog("open");
  });
  $("#upload_vip_info_file_requirement").click(function(event) {
    event.preventDefault(event);
    $("#upload_vip_info_requirment_modal").dialog("open");
  });
});
