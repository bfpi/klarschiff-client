module ClientConfig
  extend ActiveSupport::Concern

  included do
    helper_method :display?, :login_required?, :service_code, :multi_requests_enabled?, :max_image_size
  end
  
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

  def max_image_size
    Settings::Client.max_image_size
  end
end
