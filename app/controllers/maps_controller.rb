class MapsController < ApplicationController
  def show
    @show_non_job_features = !params[:type].eql?("jobs")
    @bbox = params[:bbox] if params[:bbox].present?
  end
end
