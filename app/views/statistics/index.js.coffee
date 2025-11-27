
$('.static-overlay .static-overlay-content').html('<%= j render(partial: "index").html_safe %>')
$('.static-overlay').show()
KS.initializeHeatmap()
