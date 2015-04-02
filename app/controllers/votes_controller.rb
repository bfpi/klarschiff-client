class VotesController < ApplicationController
  def new
    @request = Request.find(params[:request_id])
    @vote = Vote.new(service_request_id: @request.id, author: @user.email)
    respond_to do |format|
      format.html { head :forbidden }
      format.js
    end
  end

  def create
    vote = Vote.create(params.require(:vote).permit(:author).merge(
      service_request_id: params[:request_id]))
    @errors = vote.errors unless vote.persisted?
  end
end
