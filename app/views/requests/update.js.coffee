KS.flash.show('<%= j render("application/mobile/modal") %>', <% if @redirect %>'<%= j @redirect.html_safe %>'<% end -%>)
