$('.sidebar .tab-content > *').removeClass('active')
$('.static-overlay .overlay-content').html('<%= j render(partial: "recent_requests") %>')
$('.statistic-overlay').hide()
$('.static-overlay').show()
