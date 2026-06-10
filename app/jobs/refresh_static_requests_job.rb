class RefreshStaticRequestsJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    if (proxy = ENV['HTTP_PROXY'] || ENV.fetch('http_proxy', nil)).present? # Workaround for open-uri https-proxy problem
      proxy = "http://#{proxy}" unless %r{^https?://}.match?(proxy)
      p_uri = URI.parse(proxy)
      Net::HTTP.Proxy p_uri.host, p_uri.port
    else
      Net::HTTP
    end.get URI.join(Settings::Url.ks_server_url, "#{Settings::Client.relative_url_root}/", 'requests')
  end
end
