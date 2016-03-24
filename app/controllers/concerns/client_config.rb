module ClientConfig
  extend ActiveSupport::Concern
  
  def display?(par)
    Settings::Client.send("show_#{ par }")
  end

  def login_required?
    Settings::Client.login_required
  end
end
