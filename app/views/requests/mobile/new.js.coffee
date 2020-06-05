<% if @type -%>
$('#type-select').replaceWith("<%= j render partial: 'requests/desktop/category_select', locals: { type: @type, category: nil, service_code: nil } %>")
<% else -%>
KS.clearNewFeature()
KS.map.actions().addClass 'hidden'
KS.nav.switchTo 'request', '<%= j render("requests/mobile/new") %>'
<% end -%>
