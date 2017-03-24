xml.instruct!
xml.rss version: '2.0', 'xmlns:atom' => 'http://w3.org/2005/Atom', 'xmlns:georss' => 'http://www.georss.org/georss' do
  xml.channel do
    xml.title t(".feed_title#{ '_observation' if @key.present? }", name: Settings::Client.name)
    xml.description t(".feed_description#{ '_observation' if @key.present? }", name: Settings::Client.name)
    xml.link observations_path(observation_key: @key)
    xml.language 'de-de'
    xml.tag! 'atom:link', rel: 'self', type: 'application/rss+xml', href: observations_path(observation_key: @key)
    @requests.each do |r|
      xml.item do 
        xml.title "##{r.id} #{ t(r.service.type, scope: 'service.types', count: 1) } (#{ r.service.group } - #{ r.service })"
        xml.description do
          html_cont = <<-HTML
            <b>#{ Request.human_attribute_name(:status) }</b>: #{ status(r) }<br/>
            <b>#{ Request.human_attribute_name(:status_notes) }</b>: #{ r.status_notes }<br/>
            <b>#{ Request.human_attribute_name(:votes) }</b>: #{ r.votes }<br/>
            <b>#{ Request.human_attribute_name(:description) }</b>: #{ r.description }<br/>
          HTML
          if (url = r.media_url).present?
            html_cont << <<-HTML
              <b>#{ Request.human_attribute_name(Request.human_attribute_name(:media_url)) }</b>:
              <img src='#{ url }' alt='#{ Request.human_attribute_name(:media_url) }' class='img-rounded img-responsive' />
              <br/>
            HTML
          end
          html_cont << link_to(t('.link'), [:map, request: r], target: '_blank')
          xml.cdata! html_cont
        end
        xml.georss :point, "#{ r.lat } #{ r.long }"
        url = "#{ KLARSCHIFF_URL }#{ map_path(request: r.id) }"
        xml.link url
        xml.guid url
        xml.pubDate l(r.requested_datetime.to_date)
      end
    end
  end
end
