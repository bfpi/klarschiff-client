<% if params[:cancel] -%>
KS.resetSelectedFeatures()
KS.removeDrawObservation()
$('.area-container').replaceWith("<%= j render partial: 'index' %>")
<% else -%>
<% if @context == 'districts' -%>
KS.layers.findById('observations').setVisible(true)
<% else -%>
KS.setDrawObservation()
<% end -%>
$('.area-container').replaceWith("<%= j render partial: 'areas_form' %>")
<% end -%>
