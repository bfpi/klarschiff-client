class RequestsController < ApplicationController
  def index
    @requests = Request.where(agency_responsible: @user.field_service_team)
    @requests = @requests.try(:to_a)
    respond_to do |format|
      format.html { head :forbidden }
      format.js
    end
  end

  def show
    return head(:ok) unless (id = params[:id]).present?
    @request = Request.find(id)
  end
end
