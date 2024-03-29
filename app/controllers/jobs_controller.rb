# frozen_string_literal: true

class JobsController < ApplicationController
  before_action :conditions

  def index
    return render(nothing: true) unless has_field_service_team?

    @jobs = Request.where(@conditions).try(:to_a)
    session[:referer_params] = params.slice(:center, :radius, :controller, :action, :mobile, :ids)
    respond_to do |format|
      format.js
      format.json { render json: @jobs }
    end
  end

  def notification
    @jobs = Request.where(@conditions).try(:to_a)

    session[:id_list] = @jobs.map(&:id) if session[:id_list].blank?
    @difference = @jobs.reject { |x| x if session[:id_list].include?(x.id) }

    session[:id_list] = @jobs.map(&:id)
  end

  def update
    jobs = Request.where(@conditions).to_a
    job = jobs.select { |req| req.id == params[:id].to_i }.first

    jobs.delete_at jobs.index(job)
    jobs.insert params[:index].to_i, job

    jobs.each_with_index do |j, ix|
      Request.patch(j.id, { api_key: Request.api_key, email: @user.email, job_priority: ix })
    end

    render plain: true
  end

  private

  def conditions
    @conditions = { agency_responsible: @user&.field_service_team }
    if (states = Settings::Map.default_requests_states).present?
      @conditions.update detailed_status: states
    end
  end
end
