class ObservationsController < ApplicationController
  def new
    @observation = Observation.new
    @area_code = params[:area_code].presence
    @geom = params[:geometry].presence
  end

  def create
    result =
      begin
        attrs = {}
        attrs.update(area_code: params[:area_code].gsub(' ', ', ')) if params[:area_code]
        attrs.update(geometry: params[:geometry]) if params[:geometry]
        attrs.update(problems: params[:problems]) if params[:problems]
        attrs.update(problem_service: params[:problem_service].join(', ')) if params[:problem_service]
        attrs.update(ideas: params[:ideas]) if params[:ideas]
        attrs.update(idea_service: params[:idea_service].join(', ')) if params[:idea_service]
        Observation.create(attrs)
      end
  end
end
