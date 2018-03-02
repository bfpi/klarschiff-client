<% if @cancel -%>
  KS.clearNewFeature()
  $('.request-container').replaceWith("<%= j render partial: 'requests/desktop/start_request' %>")
<% else -%>
  <% if @mobile -%>
    KS.nav.switchTo 'map'

    KS.layers.findById("features").setVisible(<%= @show_non_job_features %>)
    <% if @zoom_to_jobs -%>
    setTimeout (->
      KS.olMap.getView().fit KS.layers.findById('jobs').getSource().getExtent(), KS.olMap.getSize()
    ), 500
    <% end -%>
  <% end -%>
  <% if @bbox.present? -%>
    $('#places_search').val('')
    extent = Array(<%= @bbox.join ', ' %>)
    KS.olMap.getView().fit(extent, { size: KS.olMap.getSize(), maxZoom: KS.maxZoom - 1 })

    if KS.layers.findById('new_feature')
      KS.moveNewFeature()
  <% end -%>
<% end -%>
