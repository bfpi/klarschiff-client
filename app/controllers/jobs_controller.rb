class JobsController < ApplicationController
  def index
    conditions = { agency_responsible: @user.field_service_team}
    if (center = params[:center]).present?
      conditions.update lat: center[0], long: center[1]
    end
    conditions[:radius] = params[:radius] if params[:radius]
    @jobs = Request.where(conditions)
    @jobs = @jobs.try(:to_a)
    session[:list] = params
    session[:id_list] = @jobs.map &:id
    respond_to do |format|
      format.js
      format.json { render json: @jobs }
    end
  end
end
