# frozen_string_literal: true

Rails.application.config.after_initialize do
  I18n.load_path += Rails.root.join(Settings::Client.resources_path).glob('locales/*.yml').map(&:to_s)
end
