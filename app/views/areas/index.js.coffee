<% if params[:cancel] -%>
<% if @context == 'districts' -%>
KS.resetSelectedFeatures()
<% else -%>
KS.removeDrawObservation()
<% end -%>
$('.area-container').replaceWith("<%= j render partial: 'index' %>")
<% else -%>
<% if @context == 'districts' -%>
KS.layers.findById('observations').setVisible(true)
<% else -%>
KS.setDrawObservation()
<% end -%>
$('.area-container').replaceWith("<%= j render partial: 'areas_form' %>")
<% end -%>
