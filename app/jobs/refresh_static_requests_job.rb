class RefreshStaticRequestsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    if (proxy = ENV['HTTP_PROXY'] || ENV['http_proxy']).present? # Workaround for open-uri https-proxy problem
      proxy = "http://#{proxy}" unless proxy.match(%r{^https?://})
      p_uri = URI.parse(proxy)
      Net::HTTP.Proxy p_uri.host, p_uri.port
    else
      Net::HTTP
    end.get URI.join(Settings::Url.ks_server_url, 'requests')
  end
end
