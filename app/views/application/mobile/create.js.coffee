KS.flash.show('<%= j render("/application/mobile/create") %>', <% if @redirect %>'<%= j @redirect.html_safe %>'<% end -%>)
