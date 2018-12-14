class ProtocolsController < ApplicationController
  def new
    @request = Request.find(params[:request_id])
    @protocol = Protocol.new message_number: @request.id
    @protocol.user = @user ? @user.name : ''
    @id_list = params[:id_list].try(:map, &:to_i).presence
    respond_to do |format|
      format.html { head :forbidden }
      format.js { render "/application/#{ context }/new" }
    end
  end

  def create
    protocol = Protocol.new(params[:protocol])
    ProtocolMailer.protocol(protocol).deliver_now
    @redirect = request_path(params[:request_id], id_list: params[:protocol][:id_list]).html_safe
    @success = I18n.t('protocols.create.success_text')
    render "/application/#{ context }/create"
  end
end
