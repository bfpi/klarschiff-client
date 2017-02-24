class VotesController < ApplicationController
  def new
    @request = Request.where(id: params[:request_id], extensions: true).first
    @vote = Vote.new(service_request_id: @request.id, author: login_required? ? @user.email : nil)
    @id_list = params[:id_list].try(:map, &:to_i).presence
    respond_to do |format|
      format.html { head :forbidden }
      format.js { render "/application/#{ context }/new" }
    end
  end

  def create
    vote = Vote.create(params.require(:vote).permit(:author).merge(
      service_request_id: params[:request_id]))
    @redirect = request_path(params[:request_id], id_list: params[:vote][:id_list], mobile: @mobile).html_safe
    @errors = vote.errors unless vote.persisted?
    render "/application/#{ context }/create"
  end
end
