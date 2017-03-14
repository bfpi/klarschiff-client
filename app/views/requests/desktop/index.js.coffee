highlight_layer = KS.layers.findById('highlight_layer')
highlight_layer.getSource().clear()
if $('.overlay').length > 0
  $('.overlay').replaceWith('')
  $('.request-container').show()
else
  $('.request-container').replaceWith("<%= j render partial: '/requests/desktop/start_request' %>")
