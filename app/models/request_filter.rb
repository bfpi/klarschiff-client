# frozen_string_literal: true

# Conditions for searching requests in the CitySDK interface of the backoffice
class RequestFilter
  PARAMETERS = { area: :area_code, map: :map, service_code: :service_code }.freeze

  # Conditions for a single request, which is only available in the states shown on the map
  def self.single(id)
    conditions = { service_request_id: id }
    states = Settings::Map.default_requests_states
    conditions[:detailed_status] = states if states.present?
    conditions[:also_archived] = true if also_archived?
    conditions
  end

  def self.also_archived?
    Settings::Client.respond_to?(:also_archived) && Settings::Client.also_archived
  end

  # The type and state filters are only available on desktop, the agency of the user only with login
  def initialize(params, mobile:, user: nil, service_code: nil)
    @params = params
    @mobile = mobile
    @user = user
    @service_code = service_code
  end

  def conditions
    conditions = agency_conditions
    conditions[:service_code] = @service_code if @service_code
    conditions.merge(parameter_conditions, keyword_conditions, state_conditions, archive_conditions,
      radius: params[:radius])
  end

  private

  attr_reader :params

  def agency_conditions
    return {} unless @user

    { agency_responsible: @user.field_service_team, negation: 'agency_responsible' }
  end

  def parameter_conditions
    PARAMETERS.filter_map { |param, key| [key, params[param]] if params[param] }.to_h
              .merge(id_conditions, start_date_conditions, center_conditions)
  end

  def id_conditions
    params[:ids] ? { service_request_id: params.expect(ids: []).join(',') } : {}
  end

  def start_date_conditions
    params[:start_date] ? { start_date: I18n.l(DateTime.parse(params[:start_date]), format: :citysdk) } : {}
  end

  def center_conditions
    (center = params[:center]).present? ? { lat: center[0], long: center[1] } : {}
  end

  def keyword_conditions
    return {} if @mobile || params[:typ].nil?

    { keyword: params[:typ].select(&:presence).join(', ') }
  end

  def state_conditions
    return {} if (states = Settings::Map.default_requests_states).blank?
    return { detailed_status: states } if @mobile || params[:status].nil?

    selected = params[:status].select(&:presence)
    { detailed_status: selected.join(', '), status: ('' if selected.blank?) }.compact
  end

  def archive_conditions
    self.class.also_archived? && params[:archive].present? ? { also_archived: true } : {}
  end
end
