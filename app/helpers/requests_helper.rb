module RequestsHelper
  def mark_trust(request)
    trust = request.extended_attributes.trust
    content_tag(:span, class: 'label label-default') do 
      content_tag(:span) do
        trust.times do
          concat content_tag(:i, nil, class: 'fas fa-star')
        end
      end
    end if trust > 0
  end

  def mark_photo_required(request)
    if request.extended_attributes.photo_required
      content_tag :i, nil, class: 'fas fa-camera', "title" => t('requests.desktop.show.hint_photo_required')
    end
  end

  def status(request, show_currently: true)
    status = t(request.detailed_status.downcase, scope: :status)
    if date = request.extended_attributes.detailed_status_datetime
      status << " (#{ t('requests.status.since') } #{ l(date.to_date) })"
    end
    status << ", #{ t('requests.status.currently') } #{ request.agency_responsible }" if show_currently
    status
  end

  def statuses(request)
    Settings::Map.default_requests_states.split(', ').select { |st|
      st.in?(Settings::Request.permissable_states | [request.detailed_status])
    }.map { |st| [t(st.downcase, scope: :status), st] }
  end

  def categories(type, current = nil)
    categories = Service.collection.select { |s| s.type == type }.map(&:group).uniq
    unless current
      categories.insert 0, [t('placeholder.select.category'), disabled: true, selected: current.nil?, class: :placeholder]
    end
    options_for_select categories, current
  end

  def services(category = nil, current = nil)
   services = Service.collection.select { |s| s.group == category }.map { |s|
      [s.service_name, s.service_code]
    }.insert 0, [t('placeholder.select.service'), disabled: true, class: :placeholder]
   options_for_select services, current
  end

  def service
    Service.find(service_code) if service_code
  end

  def d3_document_url(request)
    street = ''
    housenumber = ''
    housenumber_addition = ''

    uri = URI(Settings::AddressSearch.url)
    query = "#{request.long},#{request.lat}"
    uri.query = URI.encode_www_form(key: Settings::AddressSearch.api_key, query: query, type: 'reverse', class: 'address', radius: '100', in_epsg: '4326')

    res = if (proxy = ENV['HTTP_PROXY'] || ENV['http_proxy']).present? # Workaround for open-uri https-proxy problem
      proxy = "http://#{proxy}" unless proxy.match(%r{^https?://})
      p_uri = URI.parse(proxy)
      Net::HTTP.Proxy p_uri.host, p_uri.port
    else
      Net::HTTP
    end.get_response uri

    if res && res.message.include?('OK')
      places = ActiveSupport::JSON.decode(res.body)['features']
      places.each do |p|
        if p['properties']['objektgruppe'] == 'Adresse'
          street = p['properties']['strasse_name'] + ' (' + p['properties']['strasse_schluessel'] + ' – ' + p['properties']['gemeindeteil_name'] + ')'
          housenumber = p['properties']['hausnummer']
          if p['properties']['hausnummer_zusatz']
            housenumber_addition = p['properties']['hausnummer_zusatz']
          end
          break
        elsif p['properties']['objektgruppe'] == 'Straße' && street.blank?
          street = p['properties']['strasse_name'] + ' (' + p['properties']['strasse_schluessel'] + ' – ' + p['properties']['gemeindeteil_name'] + ')'
        end
      end
      if street.blank?
        street = t(:not_assignable)
      end
    else
      street = t(:not_assignable)
    end
    request.service.document_url.
        gsub('{ks_id}', request.id.to_s).
        gsub('{ks_user}', @user.login).
        gsub('{ks_str}', street).
        gsub('{ks_hnr}', housenumber).
        gsub('{ks_hnr_z}', housenumber_addition).
        gsub('{ks_eigentuemer}', request.extended_attributes.property_owner.truncate(254, omission: '…'))
  end
end
