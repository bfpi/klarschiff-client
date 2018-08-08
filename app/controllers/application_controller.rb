class ApplicationController < ActionController::Base
  include ClientConfig
  before_action :authenticate, if: :login_required?
  before_action :set_mobile, :set_og_request
  helper_method :has_field_service_team?, :context
  protect_from_forgery with: :exception 
  skip_before_action :verify_authenticity_token, if: :development? 

  protected

  def set_mobile
    client = DeviceDetector.new(request.user_agent)
    @mobile = (params[:mobile].presence && params[:mobile] == "true") || (client.known? && client.device_type != 'desktop')
  end

  def set_og_request
    if (id = params[:request]).present?
      @og_request = Request.find(id)
    end
  end

  def authenticate
    @user = if (name = request.env["AUTHENTICATE_FULLNAME"] || name = request.env["AUTHENTICATE_DISPLAYNAME"])
              Ldap.login2(name.force_encoding("UTF-8"))
            else
              authenticate_with_http_basic { |user, pwd| Ldap.login(user, pwd) }
            end
    request_http_basic_authentication unless @user
  end

  def has_field_service_team?
    (@user && @user.field_service_team).presence
  end

  def context
    @mobile ? 'mobile' : 'desktop'
  end

  def development?
    Rails.env == 'development'
  end
end
