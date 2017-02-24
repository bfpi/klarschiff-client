class AbusesController < ApplicationController
  def new
    @request = Request.where(id: params[:request_id], extensions: true).first
    @abuse = Abuse.new(service_request_id: @request.id, author: login_required? ? @user.email : nil,
                       comment: nil)
    @id_list = params[:id_list].try(:map, &:to_i).presence
    respond_to do |format|
      format.html { head :forbidden }
      format.js { render "/application/#{ context }/new" }
    end
  end

  def create
    abuse = Abuse.create(params.require(:abuse).permit(:author, :comment).merge(
      service_request_id: params[:request_id]))
    @redirect = request_path(params[:request_id], id_list: params[:abuse][:id_list]).html_safe
    @errors = abuse.errors unless abuse.persisted?
    render "/application/#{ context }/create"
  end
end
