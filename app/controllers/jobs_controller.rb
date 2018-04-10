class JobsController < ApplicationController
  before_action :conditions

  def index
    return render(nothing: true) unless has_field_service_team?

    @jobs = Request.where(@conditions).try(:to_a)
    session[:job_notification] = (!(session[:id_list].nil?) && session[:id_list] != @jobs.map(&:id).sort)

    session[:referer_params] = params.slice(:center, :radius)
    session[:id_list] = @jobs.map(&:id).sort
    respond_to do |format|
      format.js
      format.json { render json: @jobs }
    end
  end

  def notification
    @play_notification = true if session[:job_notification]
    session[:job_notification] = false
  end

  def update
    jobs = Request.where(@conditions).to_a
    job = jobs.select { |req| req.id == params[:id].to_i }.first

    jobs.delete_at jobs.index(job)
    jobs.insert params[:index].to_i, job

    jobs.each_with_index do |j, ix|
      Request.patch(j.id, { api_key: Request.api_key, email: @user.email, job_priority: ix })
    end

    return render text: true
  end

  private

  def conditions
    @conditions = { agency_responsible: @user&.field_service_team }
    if (states = Settings::Map.default_requests_states).present?
      @conditions.update detailed_status: states
    end
  end
end
