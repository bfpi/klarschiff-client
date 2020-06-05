class ApplicationController < ActionController::Base
  include ClientConfig
  before_action :authenticate, if: :login_required?
  before_action :set_mobile, :set_og_request
  helper_method :has_field_service_team?, :context
  protect_from_forgery prepend: true
  skip_before_action :verify_authenticity_token, if: :development? 

  protected

  def set_mobile
    @mobile = (params[:mobile].presence && params[:mobile] == "true") || mobile_detected?
  end

  def set_og_request
    if (id = params[:request]).present? && id.to_s =~ /\A[0-9]+\z/
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

  private

  def mobile_detected?
    client = DeviceDetector.new(request.user_agent)
    if client.known? && client.device_type != 'desktop'
      true
    else
      false
    end
  end
end
