# frozen_string_literal: true

xml.instruct!
xml.rss version: '2.0', 'xmlns:atom': 'http://w3.org/2005/Atom', 'xmlns:georss': 'http://www.georss.org/georss' do
  xml.channel do
    xml.title t(".feed_title#{'_observation' if @key.present?}", name: Settings::Client.name)
    xml.tag! 'atom:link', rel: 'self', type: 'application/rss+xml', href: observations_path(observation_key: @key)
    xml.link Settings::Url.ks_server_url + observations_path(observation_key: @key, format: :xml)
    xml.description t(".feed_description#{'_observation' if @key.present?}", name: Settings::Client.name,
      city_long: Settings::Client.city_long)
    xml.language 'de-de'
    @requests.each do |r|
      xml.item do
        xml.title "##{r.id} #{t(r.service.type, scope: 'service.types', count: 1)} (#{r.service.group} – #{r.service})"
        xml.description { xml.cdata! feed_description(r) }
        xml.georss :point, "#{r.lat} #{r.long}"
        url = "#{Settings::Url.ks_server_url}#{map_path(request: r.id)}"
        xml.link url
        xml.guid url
        xml.pubDate DateTime.parse(r.requested_datetime).rfc2822
      end
    end
  end
end
