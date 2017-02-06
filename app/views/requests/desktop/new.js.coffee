<% if params[:switch_type] -%>
$('#type-select').replaceWith("<%= j render partial: 'requests/desktop/category_select', locals: { type: @type } %>")
<% else -%>
KS.olMap.removeInteraction KS.newFeatureInteraction
$('.request-container').replaceWith("<%= j render partial: 'requests/desktop/new' %>")
<% end -%>
