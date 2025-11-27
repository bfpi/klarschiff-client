
$('.static-overlay .static-overlay-content').html('<%= j render(partial: 'recent_requests').html_safe %>')
$('.static-overlay').show()
$('#request, #watch').removeClass('active')
