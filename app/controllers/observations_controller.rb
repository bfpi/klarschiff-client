class ObservationsController < ApplicationController
  def new
    @observation = Observation.new
    @area_codes = params[:area_code].presence
  end
end
