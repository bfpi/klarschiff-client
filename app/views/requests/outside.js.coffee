<% unless @coord.redirect_url.blank? %>
location.href = '<%= @coord.redirect_url %>/map?new_position=<%= @request.long %>,<%= @request.lat %>'
<% else %>
KS.flash.show('<%= j render("application/#{ context }/modal") %>', '<%= @redirect %>')
<% end -%>
