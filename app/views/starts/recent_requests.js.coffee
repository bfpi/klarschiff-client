
$('.static-overlay .static-overlay-content').html('<%= j render(partial: 'recent_requests').html_safe %>')
$('.static-overlay').show()
$('.sidebar .tab-content > *').removeClass('active')
