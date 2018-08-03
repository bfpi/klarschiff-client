<% if @errors.present? -%>
overlay = if $('.overlay').length > 0 then '.overlay ' else ''
$("#{ overlay }.errors").replaceWith("<%= j render partial: 'application/desktop/errors' %>")
<% else -%>
if $('.overlay').length > 0
  $('.overlay').replaceWith('<div class="request-container overlay"><%= j render partial: "#{ controller_name }/desktop/new" %></div>')
else
  $('.request-container').replaceWith('<%= j render partial: "/#{ controller_name }/desktop/new" %>')
<% end -%>
