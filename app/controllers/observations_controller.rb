class ObservationsController < ApplicationController
  helper :requests
  
  def index
    respond_to do |format|
      format.xml do
        if (@key = params[:observation_key]).present?
          @requests = Request.where(observation_key: @key, extensions: true)
        else
          states = Settings::Map.default_requests_states.strip.split(', ').reject { |s| s == 'PENDING' }.join(', ')
          @requests = Request.where(detailed_status: states, keyword: 'problem, idea')
        end
      end
    end
  end

  def new
    @observation = Observation.new
    @area_code = params[:area_code].presence
    @geom = params[:geometry].presence
  end

  def create
    @observation = Observation.new
    if (Array.wrap(params[:problem_service]) | Array.wrap(params[:idea_service]) | Array.wrap(params[:problem_service_sub]) | Array.wrap(params[:idea_service_sub])).blank?
      @area_code = params[:area_code].presence
      @geom = params[:geometry].presence
      @error = I18n.t('messages.errors.services_required')
      return render :new
    end
    attrs = {}
    attrs.update(area_code: params[:area_code].gsub(' ', ', ')) if params[:area_code]
    attrs.update(geometry: params[:geometry])
    attrs.update(problems: params[:problem_service].present? || params[:problem_service_sub].present?)
    attrs.update(problem_service: params[:problem_service].join(', ')) if params[:problem_service]
    attrs.update(problem_service_sub: params[:problem_service_sub].join(', ')) if params[:problem_servicev]
    attrs.update(ideas: params[:idea_service].present? || params[:idea_service_sub].present?)
    attrs.update(idea_service: params[:idea_service].join(', ')) if params[:idea_service]
    attrs.update(idea_service_sub: params[:idea_service_sub].join(', ')) if params[:idea_service_sub]
    result = Observation.connection.post(Observation.collection_path, Observation.format.encode(attrs))
    @rss_id = @observation.load(Observation.format.decode(result.body)).rss_id
  end
end
