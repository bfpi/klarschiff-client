<% if @errors.present? -%>
$('.errors').replaceWith("<%= j render partial: 'application/desktop/errors' %>")
<% else -%>
$('.request-container').replaceWith('<%= render partial: "/#{ controller_name }/desktop/new" %>')
<% end -%>
