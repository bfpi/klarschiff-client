class ApplicationController < ActionController::Base
  include ClientConfig
  before_action :authenticate, if: :login_required?
  helper_method :display?
  protect_from_forgery with: :exception

  protected
  def authenticate
    @user = if name = request.env["AUTHENTICATE_FULLNAME"]
              Ldap.login2(name)
            else
              authenticate_with_http_basic { |user, pwd| Ldap.login(user, pwd) }
            end
    request_http_basic_authentication unless @user
  end

  def login_required?
    @login_required ||= Settings::Client.login_required
  end
end
