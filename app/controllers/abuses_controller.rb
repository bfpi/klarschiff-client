class AbusesController < ApplicationController
  def new
    @request = Request.find(params[:request_id])
    @abuse = Abuse.new(service_request_id: @request.id, author: @user.email, comment: nil)
    respond_to do |format|
      format.html { head :forbidden }
      format.js
    end
  end

  def create
    abuse = Abuse.create(params.require(:abuse).permit(:author, :comment).merge(
      service_request_id: params[:request_id]))
    @redirect = request_url(params[:request_id])
    @errors = abuse.errors unless abuse.persisted?
  end
end
