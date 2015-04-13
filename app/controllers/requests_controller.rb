class RequestsController < ApplicationController
  def index
    conditions = { agency_responsible: @user.field_service_team }
    conditions[:negation] = "agency_responsible" unless params[:type].eql? "jobs"
    @requests = Request.where(conditions)
    @requests = @requests.try(:to_a)
    respond_to do |format|
      format.html { head :forbidden }
      format.js
      format.json { render json: @requests }
    end
  end

  def show
    return head(:ok) unless (id = params[:id]).present?
    @request = Request.find(id)
  end
end
