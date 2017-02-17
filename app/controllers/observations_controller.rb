class ObservationsController < ApplicationController
  def new
    @observation = Observation.new
  end
end
