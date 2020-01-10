class JobsController < ApplicationController
  before_action :conditions

  def index
    return render(nothing: true) unless has_field_service_team?

    @jobs = Request.where(@conditions).try(:to_a)
    @jobs.sort! { |x, y| x.extended_attributes.job_priority <=> y.extended_attributes.job_priority}
    session[:referer_params] = params.slice(:center, :radius)
    respond_to do |format|
      format.js
      format.json { render json: @jobs }
    end
  end

  def notification
    @jobs = Request.where(@conditions).try(:to_a)

    session[:id_list] = @jobs.map(&:id) if session[:id_list].blank?
    @difference = @jobs.reject{|x| x if session[:id_list].include?(x.id) }

    session[:id_list] = @jobs.map(&:id)
  end

  def update
    jobs = Request.where(@conditions).to_a
    jobs.sort! { |x, y| x.extended_attributes.job_priority <=> y.extended_attributes.job_priority}
    job = jobs.select { |req| req.id == params[:id].to_i }.first

    jobs.delete_at jobs.index(job)
    jobs.insert params[:index].to_i, job

    jobs.each_with_index do |j, ix|
      Request.patch(j.id, { api_key: Request.api_key, email: @user.email, job_priority: ix })
    end

    return render plain: true
  end

  private

  def conditions
    @conditions = { agency_responsible: @user&.field_service_team }
    if (states = Settings::Map.default_requests_states).present?
      @conditions.update detailed_status: states
    end
  end
end
