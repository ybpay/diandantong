var initProductActions = function () {
  'use strict';

  //
  // Tiered Calculator
  //
  if ($('#tier-fields-template').length && $('#tier-input-name').length) {
    var tierFieldsTemplate = Handlebars.compile($('#tier-fields-template').html());
    var tierInputNameTemplate = Handlebars.compile($('#tier-input-name').html());

    var originalTiers = $('.js-original-tiers').data('original-tiers');
    $.each(originalTiers, function(base, value) {
      var fieldName = tierInputNameTemplate({base: base}).trim();
      $('.js-tiers').append(tierFieldsTemplate({
        baseField: {value: base},
        valueField: {name: fieldName, value: value}
      }));
    });

    $(document).on('click', '.js-add-tier', function(event) {
      event.preventDefault();
      $('.js-tiers').append(tierFieldsTemplate({valueField: {name: null}}));
    });

    $(document).on('click', '.js-remove-tier', function(event) {
      $(this).parents('.tier').remove();
    });

    $(document).on('change', '.js-base-input', function(event) {
      var valueInput = $(this).parents('.tier').find('.js-value-input');
      valueInput.attr('name', tierInputNameTemplate({base: $(this).val()}).trim());
    });
  }

};

$(function () {

  initProductActions();

});