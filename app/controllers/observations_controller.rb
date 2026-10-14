# frozen_string_literal: true

class ObservationsController < ApplicationController
  SERVICES = %i[problem_service problem_service_sub idea_service idea_service_sub].freeze

  helper :requests

  def index
    respond_to do |format|
      format.xml do
        @key = params[:observation_key]
        @requests = Request.where(feed_conditions)
      end
    end
  end

  def new
    @observation = Observation.new
    assign_area
  end

  def create
    @observation = Observation.new
    return render_missing_services unless selected?(*SERVICES)

    @rss_id = @observation.load(post_observation).rss_id
  end

  private

  def render_missing_services
    assign_area
    @error = I18n.t('messages.errors.services_required')
    render :new
  end

  def post_observation
    result = Observation.connection.post(Observation.collection_path, Observation.format.encode(observation_attributes))
    Observation.format.decode(result.body)
  end

  def feed_conditions
    return { observation_key: @key, extensions: true } if @key.present?

    { detailed_status: helpers.states, keyword: 'problem, idea' }
  end

  def assign_area
    @area_code = params[:area_code].presence
    @geom = params[:geometry].presence
  end

  def observation_params
    @observation_params ||= params.permit(:area_code, :geometry, **SERVICES.index_with { [] })
  end

  def selected?(*services)
    observation_params.values_at(*services).any?(&:present?)
  end

  def observation_attributes
    attributes = { geometry: observation_params[:geometry], problems: selected?(:problem_service, :problem_service_sub),
                   ideas: selected?(:idea_service, :idea_service_sub) }
    attributes[:area_code] = observation_params[:area_code].gsub(' ', ', ') if observation_params[:area_code]
    attributes.merge(selected_services)
  end

  def selected_services
    SERVICES.filter_map { |service| [service, observation_params[service].join(', ')] if observation_params[service] }
            .to_h
  end
end
