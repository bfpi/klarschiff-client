# frozen_string_literal: true

class JobsController < ApplicationController
  before_action :conditions

  def index
    return head(:ok) unless field_service_team?

    @jobs = Request.where(@conditions).try(:to_a)
    session[:referer_params] = params.slice(:center, :radius, :controller, :action, :mobile, :ids)
    respond_to do |format|
      format.js
      format.json { render json: @jobs }
    end
  end

  def notification
    job_ids = (@jobs = Request.where(@conditions).try(:to_a)).map(&:id)
    known_ids = session[:id_list].presence || job_ids
    @difference = @jobs.reject { |job| known_ids.include?(job.id) }
    session[:id_list] = job_ids
  end

  def update
    reordered_jobs.each_with_index do |job, ix|
      Request.patch(job.id, { api_key: Request.api_key, email: @user.email, job_priority: ix })
    end
    render plain: true
  end

  private

  # Moves the job to the requested position in the list
  def reordered_jobs
    jobs = Request.where(@conditions).to_a
    job = jobs.find { |req| req.id == params[:id].to_i }
    jobs.delete(job)
    jobs.insert(params[:index].to_i, job)
  end

  def conditions
    @conditions = { agency_responsible: @user&.field_service_team }
    if (states = Settings::Map.default_requests_states).present?
      @conditions.update detailed_status: states
    end
  end
end
