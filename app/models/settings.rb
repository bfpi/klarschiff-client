class Settings
  # Defines accessors for application configuration with values
  # defined in config/settings.yml
  # Each root node becomes an own module to scope the options
  @@config ||= File.open(Rails.root.join('config', 'settings.yml')) { |file|
    YAML::load file
  }.with_indifferent_access.each do |context, options|
    m = Module.new
    options.each do |name, value|
      m.define_singleton_method(name) { value }
    end
    const_set context.classify, m
  end

  module Route
    class << self
      include Rails.application.routes.url_helpers
      #include ActionView::Helpers::AssetUrlHelper
    end
  end
end
