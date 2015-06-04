class JobsController < ApplicationController
  def index
    conditions = { agency_responsible: @user.field_service_team }
    if (center = params[:center]).present?
      conditions.update lat: center[0], long: center[1]
    end
    if (states = Settings::Map.default_requests_states).present?
      conditions.update detailed_status: states
    end
    @jobs = Request.where(conditions.merge(params.slice(:radius))).try(:to_a)
    session[:referer_params] = params.slice(:controller, :action, :ids)
    session[:id_list] = @jobs.map(&:id)
    respond_to do |format|
      format.js
      format.json { render json: @jobs }
    end
  end

  def update
    conditions = { agency_responsible: @user.field_service_team }
    jobs = Request.where(conditions).to_a
    job = jobs.select { |req| req.id == params[:id].to_i }.first

    jobs.delete_at jobs.index(job)
    jobs.insert params[:index].to_i, job

    jobs.each_with_index do |j, ix|
      Request.patch(j.id, { api_key: Request.api_key, email: @user.email, job_priority: ix })
    end

    return render text: true
  end
end
