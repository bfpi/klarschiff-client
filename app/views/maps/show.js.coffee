KS.nav.switchTo 'map'

KS.layers.findById("features").setVisible(<%= @show_non_job_features %>)

<% if @bbox.present? -%>
KS.olMap.getView().fitExtent Array(<%= @bbox.join ", " %>), KS.olMap.getSize()
<% end -%>
