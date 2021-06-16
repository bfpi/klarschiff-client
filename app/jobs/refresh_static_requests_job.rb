class RefreshStaticRequestsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Net::HTTP.get URI.parse("#{Settings::Url.ks_server_url}/requests")
  end
end
