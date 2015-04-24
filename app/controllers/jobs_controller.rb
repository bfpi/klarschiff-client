class JobsController < ApplicationController
  def index
    conditions = { agency_responsible: @user.field_service_team}
    if (center = params[:center]).present?
      conditions.update lat: center[0], long: center[1]
    end
    @jobs = Request.where(conditions.merge(params.slice(:radius))).try(:to_a)
    session[:referer_params] = params.slice(:controller, :action, :ids)
    session[:id_list] = @jobs.map(&:id)
    respond_to do |format|
      format.js
      format.json { render json: @jobs }
    end
  end
end
