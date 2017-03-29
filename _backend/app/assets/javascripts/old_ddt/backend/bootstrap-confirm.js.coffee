$.rails.allowAction = (link) ->
  return true unless link.attr('data-confirm')
  $.rails.showConfirmDialog(link) # look bellow for implementations
  false # always stops the action since code runs asynchronously

$.rails.confirmed = (link) ->
  link.removeAttr('data-confirm')
  link.trigger('click.rails')

$.rails.showConfirmDialog = (link) ->
  message = link.attr 'data-confirm'
  bootbox.confirm message, (result) ->
    if result
      $.rails.confirmed(link)

$.rails.confirm = (message, func) ->
  bootbox.confirm message, (result) ->
    if result
      func()