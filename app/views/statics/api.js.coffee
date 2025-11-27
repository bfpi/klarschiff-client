
$('.static-overlay .static-overlay-content').html('<%= j render(file: "#{ Settings::Client.resources_path }/#{ @file_name }.html").html_safe %>')
$('.static-overlay').show()
$('#request, #watch').removeClass('active')
