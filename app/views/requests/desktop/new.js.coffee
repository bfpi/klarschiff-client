<% if params[:switch_type] -%>
$('#type-select').replaceWith("<%= j render partial: 'requests/desktop/category_select', locals: { type: @type } %>")
<% else -%>
$('.request-container').replaceWith("<%= j render partial: 'requests/desktop/new' %>")
<% end -%>
