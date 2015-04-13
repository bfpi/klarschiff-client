class JobsController < ApplicationController
  def index
    conditions = { agency_responsible: @user.field_service_team}
    #conditions[:negation] = "agency_responsible"
    @jobs = Request.where(conditions)
    @jobs = @jobs.try(:to_a)
    respond_to do |format|
      format.js
      format.json { render json: @jobs }
    end
  end
end
