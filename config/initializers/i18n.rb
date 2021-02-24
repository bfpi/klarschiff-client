Rails.application.config.after_initialize do
  I18n.load_path += Dir[Settings::Client.resources_path + 'locales/*.yml']
end
