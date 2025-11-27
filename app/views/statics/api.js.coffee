
$('.sidebar .tab-content > *').removeClass('active')
$('.static-overlay .static-overlay-content').html('<%= j render(file: "#{ Settings::Client.resources_path }/#{ @file_name }.html").html_safe %>')
<% if File.exist?("#{ Settings::Client.resources_path }/#{ @file_name }_sidebar.html") %>
$('.sidebar .tab-content .static').html('<%= j render(file: "#{ Settings::Client.resources_path }/#{ @file_name }_sidebar.html").html_safe %>')
$('.sidebar .tab-content .static').show()
<% end -%>
$('.static-overlay').show()
