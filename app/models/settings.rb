class Settings
  # Defines accessors for global application configuration with values
  # defined in global block in config/settings.yml
  File.open(Rails.root.join('config', 'settings.yml')) { |file| 
    YAML::load file }['global'].each do |name, value|
      define_singleton_method(name) { value }
    end
end
