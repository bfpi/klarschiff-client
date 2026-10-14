# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ClientConfig

  prepend_view_path 'overlay/views'

  before_action :authenticate, if: :login_required?
  before_action :set_mobile, :set_og_request
  helper_method :field_service_team?, :context
  protect_from_forgery prepend: true

  protected

  def set_mobile
    @mobile = (params[:mobile].presence && params[:mobile] == 'true') || mobile_detected?
  end

  def set_og_request
    if (id = params[:request]).present? && id.to_s =~ /\A[0-9]+\z/
      @og_request = Request.find(id)
    end
  end

  def authenticate
    @user ||= single_sign_on_name.present? ? single_sign_on_user : http_basic_user
    request_http_basic_authentication unless @user&.valid?
  end

  def field_service_team?
    @user&.field_service_team.present?
  end

  def context
    ActiveSupport::StringInquirer.new @mobile ? 'mobile' : 'desktop'
  end

  private

  def single_sign_on_name
    request.env['AUTHENTICATE_FULLNAME'].presence || request.env['AUTHENTICATE_DISPLAYNAME']
  end

  def single_sign_on_user
    User.where(login: single_sign_on_name, api_key: User.api_key)&.first
  end

  def http_basic_user
    authenticate_with_http_basic do |user, pwd|
      User.create(login: user, password: pwd, api_key: User.api_key)
    end
  end

  def privacy_policy_params(model_name = controller_name.singularize.to_sym)
    { privacy_policy_accepted: params[model_name][:privacy_policy_accepted].present? || login_required? }
  end

  def id_list_param
    params[:id_list].try(:map, &:to_i).presence
  end

  def mobile_detected?
    client = DeviceDetector.new(request.user_agent)
    client.known? && client.device_type != 'desktop'
  end
end
