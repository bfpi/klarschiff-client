class ApplicationController < ActionController::Base
  before_action :authenticate
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
end
