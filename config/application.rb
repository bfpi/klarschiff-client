require_relative 'boot'

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
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module KlarschiffFieldService
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    config.i18n.default_locale = :de
    config.time_zone = 'Berlin'

    ActionView::RecordIdentifier.send(:remove_const, "JOIN")
    ActionView::RecordIdentifier.const_set("JOIN", "-")

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Global settings from settings.yml
    settings = File.open(Rails.root.join('config', 'settings.yml')) { |file|
      YAML::load file
    }.with_indifferent_access.dig(Rails.env)

    relative_url_root = settings.dig(:client, :relative_url_root)
    config.action_controller.relative_url_root = relative_url_root if relative_url_root.present?

    # Configuration for SMTP-Server
    smtp_settings = settings.dig(:protocol_mail, :smtp)
    config.action_mailer.smtp_settings = {
      :address => smtp_settings[:host],
      :enable_starttls_auto => smtp_settings[:starttls_enabled],
      :user_name => smtp_settings[:username],
      :password => smtp_settings[:password]
    }
  end
end
