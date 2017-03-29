
//= require_tree ./webpos/providers/
//= require_tree ./webpos/directives/
//= require_tree ./webpos/services/
//= require_tree ./webpos/controllers/
//= require_tree ./webpos/actions/
//= require ./webpos/application

$(function(){
  $('[data-rel=tooltip]').tooltip();
  $('[data-rel=popover]').popover({html:true});
  $('.dropdown-toggle').dropdown()

})

// datatimepicker
$.fn.datetimepicker.defaults = {
    pickDate: true,
    pickTime: true,
    useMinutes: true,
    useSeconds: false,
    useCurrent: true,
    minuteStepping: 1,
    format: 'YYYY-MM-DD hh:mm',
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

