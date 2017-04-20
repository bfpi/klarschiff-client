class ApplicationController < ActionController::Base
  include ClientConfig
  before_action :authenticate, if: :login_required?
  before_action :set_mobile
  # methods from ClientConfig concern
  helper_method :display?, :login_required?, :imprint, :multi_requests_enabled?
  helper_method :has_field_service_team?, :context
  protect_from_forgery with: :exception 
  skip_before_action :verify_authenticity_token, if: :development? 

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

  def development?
    Rails.env == 'development'
  end
end
