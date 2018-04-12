module ClientConfig
  extend ActiveSupport::Concern
  
  def display?(par)
    Settings::Client.send("show_#{ par }")
  end

  def service_code
    !@mobile && Settings::Client.service_code
  end

  def login_required?
    Settings::Client.login_required
  end

  def multi_requests_enabled?
    Settings::Client.multi_requests_enabled
  end
end
