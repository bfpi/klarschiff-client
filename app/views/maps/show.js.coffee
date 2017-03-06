<% if @cancel -%>
KS.clearNewFeature()
$('.request-container').replaceWith("<%= j render partial: 'requests/desktop/start_request' %>")
<% else -%>
<% if @mobile -%>
KS.nav.switchTo 'map'

KS.layers.findById("features").setVisible(<%= @show_non_job_features %>)
<% end -%>

<% if @bbox.present? -%>
$('#places_search').val('')
KS.olMap.getView().fitExtent Array(<%= @bbox.join ", " %>), KS.olMap.getSize()
<% end -%>
<% end -%>
