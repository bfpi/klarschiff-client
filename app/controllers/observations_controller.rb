class ObservationsController < ApplicationController
  helper :requests
  
  def index
    respond_to do |format|
      format.xml do 
        @requests = Request.where(observation_key: (@key = params[:observation_key]), extensions: true)
      end
    end
  end

  def new
    @observation = Observation.new
    @area_code = params[:area_code].presence
    @geom = params[:geometry].presence
  end

  def create
    attrs = {}
    attrs.update(area_code: params[:area_code].gsub(' ', ', ')) if params[:area_code]
    attrs.update(geometry: params[:geometry])
    attrs.update(problems: params[:problem_service].present?)
    attrs.update(problem_service: params[:problem_service].join(', ')) if params[:problem_service]
    attrs.update(ideas: params[:idea_service].present?)
    attrs.update(idea_service: params[:idea_service].join(', ')) if params[:idea_service]
    result = Observation.connection.post(Observation.collection_path, Observation.format.encode(attrs))
    @rss_id = Observation.new.load(Observation.format.decode(result.body)).rss_id
  end
end
