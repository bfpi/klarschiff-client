class MapsController < ApplicationController
  def show
    return if @cancel = params[:cancel]
    @show_non_job_features = !params[:type].eql?("jobs")
    @bbox = params[:bbox] if params[:bbox].present?
  end
end
