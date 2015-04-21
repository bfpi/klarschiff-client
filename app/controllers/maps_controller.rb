class MapsController < ApplicationController
  def show
    @requests = Request.all.try(:to_a)
    @show_non_job_features = !params[:type].eql?("jobs")
    @bbox = params[:bbox] if params[:bbox].present?
  end

  def positioning
  end
end
