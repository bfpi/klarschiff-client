<% unless @back.present? -%>
KS.clearNewFeature()
KS.reloadFeatures()
<% end -%>
$('.request-container').replaceWith("<%= j render partial: '/requests/desktop/start_request' %>")
