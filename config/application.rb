require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
# require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module KlarschiffClient
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    config.autoload_paths << "#{root}/overlay/config"
    #config.autoload_paths << "#{root}/overlay/controllers"
    p config.autoload_paths.inspect

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.i18n.default_locale = :de
    config.time_zone = 'Berlin'

    ActionView::RecordIdentifier.send(:remove_const, "JOIN")
    ActionView::RecordIdentifier.const_set("JOIN", "-")

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Global settings from settings.yml
    settings_file = Rails.root.join('config/settings.yml')
    if File.file?(settings_file)
      settings = settings_file.open do |file|
        YAML.load file, aliases: true
      end.with_indifferent_access[Rails.env]

      relative_url_root = settings.dig(:client, :relative_url_root)
      config.relative_url_root = relative_url_root if relative_url_root.present?

      # Configuration for SMTP-Server
      smtp_settings = settings.dig(:protocol_mail, :smtp)
      config.action_mailer.smtp_settings = {
        :address => smtp_settings[:host],
        :enable_starttls_auto => smtp_settings[:starttls_enabled],
        :user_name => smtp_settings[:username],
        :password => smtp_settings[:password]
      }
    end

    config.after_initialize do
      Dir.glob("#{ Rails.root.join }/overlay/**/*").select { |f| f if f.include?('extension') }.each do |file|
        require file unless Rails.application.config.cache_classes
      end
    end
  end
end
