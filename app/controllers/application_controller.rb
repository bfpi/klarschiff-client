class ApplicationController < ActionController::Base
  include ClientConfig
  before_action :authenticate, if: :login_required?
  before_action :set_mobile
  helper_method :display?, :has_field_service_team?, :login_required?, :imprint, :context
  protect_from_forgery with: :exception

  protected

  def set_mobile
    @mobile = params[:mobile].presence
  end

  def authenticate
    @user = if name = request.env["AUTHENTICATE_FULLNAME"]
              Ldap.login2(name)
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
end
