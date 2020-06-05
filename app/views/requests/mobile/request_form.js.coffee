$('#confirm-new-request').replaceWith("<%= j render partial: 'requests/mobile/request_form', locals: { req: @request, service: @service, media: @media } %>")
$('#request-preview').attr('src', "data:image/jpeg;base64,#{'<%=@request.media%>'.replace(/\r|\n/, '')}")
$('#form-page-4').toggle()
$('#form-page-5').toggle()
KS.olMiniMap = new KS.MiniMap
