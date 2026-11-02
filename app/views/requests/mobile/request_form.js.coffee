$('#confirm-new-request').replaceWith("<%= j render partial: 'requests/mobile/request_form', locals: { req: @request, service: @service, media: @media } %>")
<% if @request.media.present? && @media_size < max_image_size -%>
$('#request-preview').attr('src', "data:#{'<%= @media_type %>'};base64,#{'<%=@request.media%>'.replace(/\r|\n/, '')}")
<% end -%>
<% if Settings::Client.skip_type_selection %>
$('#form-page-3').toggle()
$('#form-page-4').toggle()
<% else %>
$('#form-page-4').toggle()
$('#form-page-5').toggle()
<% end -%>
KS.olMiniMap = new KS.MiniMap
