# frozen_string_literal: true

return if (url = ENV.fetch('CACHE_URL', nil)).blank?

redis_config = {
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
  url:
}

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end
