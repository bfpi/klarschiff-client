xml.instruct!
xml.rss version: '2.0', 'xmlns:atom': 'http://w3.org/2005/Atom', 'xmlns:georss': 'http://www.georss.org/georss' do
  xml.channel do
    xml.title t(".feed_title#{ '_observation' if @key.present? }", name: Settings::Client.name)
    xml.tag! 'atom:link', rel: 'self', type: 'application/rss+xml', href: observations_path(observation_key: @key)
    xml.link Settings::Url.ks_server_url + observations_path(observation_key: @key, format: :xml)
    xml.description t(".feed_description#{ '_observation' if @key.present? }", name: Settings::Client.name)
    xml.language 'de-de'
    @requests.each do |r|
      xml.item do 
        xml.title "##{r.id} #{ t(r.service.type, scope: 'service.types', count: 1) } (#{ r.service.group } – #{ r.service })"
        xml.description do
          html_cont = <<-HTML
            <b>#{ Request.human_attribute_name(:status) }:</b> #{ status(r) }<br/>
            <b>#{ Request.human_attribute_name(:status_notes) }:</b> #{ (!r.status_notes.to_s == '' ? r.status_notes : t('.status_notes_not_available')) }<br/>
            <b>#{ Request.human_attribute_name(:votes) }:</b> #{ (r.votes > 0 ? r.votes : t('.no_votes')) }<br/>
            <b>#{ Request.human_attribute_name(:description) }:</b> #{ r.description }<br/>
            <b>#{ Request.human_attribute_name(Request.human_attribute_name(:media_url)) }:</b>
          HTML
          html_cont << if (url = r.media_url).present?
            html_cont << '<br/>'
            image_tag(url, alt: Request.human_attribute_name(:media_url), class: 'img-rounded img-responsive')
          else
            t('.img_not_available')
          end
          html_cont << '<br/>'
          html_cont << link_to(t('.link'), Settings::Url.ks_server_url + map_path(request: r), target: '_blank')
          xml.cdata! html_cont
        end
        xml.georss :point, "#{ r.lat } #{ r.long }"
        url = "#{ Settings::Url.ks_server_url }#{ map_path(request: r.id) }"
        xml.link url
        xml.guid url
        xml.pubDate DateTime.parse(r.requested_datetime).rfc2822
      end
    end
  end
end
