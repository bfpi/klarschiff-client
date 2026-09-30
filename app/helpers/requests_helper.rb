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
    Settings::Map.default_requests_states.split(', ').select do |st|
      st.in?(Settings::Request.permissable_states | [request.detailed_status])
    end.map { |st| [t(st.downcase, scope: :status), st] }
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

  def d3_document_url(request)
    street = ''
    housenumber = ''
    housenumber_addition = ''

    uri = URI.parse(Settings::AddressSearch.url)
    query_params = {
      type: 'Adresse',
      coord: "#{request.long},#{request.lat}",
      crs: 'EPSG:4326',
      rm: '50',
      n: '1'
    }
    filter = Settings::AddressSearch.localisator
    if filter && !filter.empty?
      filter = filter.delete_prefix('[')
      key, value = filter.split(']=', 2)
      query_params["x_filter[#{key}]"] = value
    end
    uri.query = URI.encode_www_form(query_params)

    uri_options = { ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE }
    if Settings::AddressSearch.respond_to?(:proxy) && Settings::AddressSearch.proxy.present?
      uri_options[:proxy] = URI.parse(Settings::AddressSearch.proxy)
    end
    begin
      if (res = uri.open(uri_options)) && res.status.include?('OK')
        JSON.parse(res.read).fetch('features', []).each do |p|
          street = "#{p['properties']['x_strassenname'][0]} (#{p['properties']['x_strassenschluessel'][0]} – #{p['properties']['x_bereich'][0]})"
          housenumber, housenumber_addition = p['properties']['x_hausnummer'][0].match(/\A(\d+)([A-Za-z]*)\z/).captures
        end
        street = t(:not_assignable) if street.blank?
      else
        street = t(:not_assignable)
      end
      request.service.document_url
             .gsub('{ks_id}', request.id.to_s)
             .gsub('{ks_user}', @user.login)
             .gsub('{ks_str}', street)
             .gsub('{ks_hnr}', housenumber)
             .gsub('{ks_hnr_z}', housenumber_addition)
             .gsub('{ks_eigentuemer}', request.extended_attributes.property_owner.truncate(254, omission: '…'))
    rescue OpenURI::HTTPError
      Rails.logger.error "Geocoding error: #{$ERROR_INFO.inspect}, #{$ERROR_INFO.message}\n"
      Rails.logger.error $ERROR_INFO.backtrace.join("\n  ")
    end
  end
end
