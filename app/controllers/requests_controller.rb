class RequestsController < ApplicationController
  def index
    @team = 'A-Team'
    @requests = Request.where(agency_responsible: @team)
    logger.info @requests.inspect
    #head :ok
  end
end
