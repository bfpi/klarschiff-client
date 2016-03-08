class ApplicationController < ActionController::Base
  before_action :load_client_config
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

  # erzeuge Instanzen aus den Konfigurationsparametern für den Client
  def load_client_config
    %w(email abuses votes create_comment comments edit_request edit_status protocol notes).each do |tmp|
      unless instance_variable_get(inst = "@show_#{ tmp }")
        instance_variable_set(inst, Settings::Client.send(inst.gsub('@', '')))
      end
    end
    authenticate if @login_required ||= Settings::Client.login_required
  end
end
