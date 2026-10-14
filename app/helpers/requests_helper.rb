# frozen_string_literal: true

module RequestsHelper
  def mark_trust(request)
    trust = request.extended_attributes.trust
    return unless trust.positive?

    content_tag(:span, class: 'label label-default') do
      content_tag(:span) do
        trust.times do
          concat content_tag(:i, nil, class: 'fas fa-star')
        end
      end
    end
  end

  def mark_photo_required(request)
    return unless request.extended_attributes.photo_required

    content_tag :i, nil, class: 'fas fa-camera', 'title' => t('requests.desktop.show.hint_photo_required')
  end

  def status(request, show_currently: true)
    status = t(request.detailed_status.downcase, scope: :status)
    if (date = request.extended_attributes.detailed_status_datetime)
      status << " (#{t('requests.status.since')} #{l(date.to_date)})"
    end
    status << ", #{t('requests.status.currently')} #{request.agency_responsible}" if show_currently
    status
  end

  def statuses(request)
    permitted = Settings::Request.permissable_states | [request.detailed_status]
    Settings::Map.default_requests_states.split(', ').filter_map do |state|
      [t(state.downcase, scope: :status), state] if state.in?(permitted)
    end
  end

  def categories(type, current = nil)
    categories = Service.collection.select { |s| s.type == type }.map(&:group).uniq
    unless current
      categories.insert 0,
        [t('placeholder.select.category'),
         { disabled: true, selected: current.nil?, class: :placeholder }]
    end
    options_for_select categories, current
  end

  def services(category = nil, current = nil)
    services = Service.collection.select { |s| s.group == category }.map do |s|
      [s.service_name, s.service_code]
    end.insert 0, [t('placeholder.select.service'), { disabled: true, class: :placeholder }]
    options_for_select services, current
  end

  def service
    Service.find(service_code) if service_code
  end

  def d3_document_url(request, user)
    street, housenumber, housenumber_addition = d3_address(request)
    placeholders = {
      '{ks_id}' => request.id.to_s, '{ks_user}' => user.login, '{ks_str}' => street, '{ks_hnr}' => housenumber,
      '{ks_hnr_z}' => housenumber_addition,
      '{ks_eigentuemer}' => request.extended_attributes.property_owner.truncate(254, omission: '…')
    }
    request.service.document_url.gsub(/\{ks_\w+\}/) { |placeholder| placeholders.fetch(placeholder, placeholder) }
  end

  private

  # Nearest address of the request, otherwise at least the nearest street
  def d3_address(request)
    places = d3_address_search(request)
    if (address = places.find { |place| place['objektgruppe'] == 'Adresse' })
      return [d3_street(address), address['hausnummer'], address['hausnummer_zusatz'] || '']
    end

    street = places.find { |place| place['objektgruppe'] == 'Straße' }
    [street ? d3_street(street) : t(:not_assignable), '', '']
  end

  def d3_street(place)
    "#{place['strasse_name']} (#{place['strasse_schluessel']} – #{place['gemeindeteil_name']})"
  end

  def d3_address_search(request)
    uri = URI(Settings::AddressSearch.url)
    uri.query = URI.encode_www_form(key: Settings::AddressSearch.api_key, query: "#{request.long},#{request.lat}",
      type: 'reverse', class: 'address', radius: '100', in_epsg: '4326')
    response = d3_http.get_response(uri)
    return [] unless response&.message&.include?('OK')

    ActiveSupport::JSON.decode(response.body)['features'].pluck('properties')
  end

  # Workaround for open-uri https-proxy problem
  def d3_http
    return Net::HTTP if (proxy = ENV['HTTP_PROXY'] || ENV.fetch('http_proxy', nil)).blank?

    proxy_uri = URI.parse(%r{^https?://}.match?(proxy) ? proxy : "http://#{proxy}")
    Net::HTTP.Proxy(proxy_uri.host, proxy_uri.port)
  end
end
