$('.static-overlay .static-overlay-content').html('<%= j render(file: "#{ Settings::Client.resources_overview_path }/#{ @page_number }.html").html_safe %>')
$('.static-overlay').show()
$('#request, #watch').removeClass('active')
