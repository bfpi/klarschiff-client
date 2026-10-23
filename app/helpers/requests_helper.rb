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
    categories = services_by_type(type)
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
    end.insert 0, [t('placeholder.select.service'), { disabled: true, class: :placeholder, selected: true }]
    options_for_select services, current
  end

  def service
    Service.find(service_code) if service_code
  end

  def multiple_main_categories?(type)
    services_by_type(type).size > 1
  end

  def services_by_type(type)
    Service.collection.select { |s| s.type == type }.map(&:group).uniq
  end

  def d3_document_url(request)
    street = t(:not_assignable)
    housenumber = ''
    housenumber_addition = ''

    if (address = Geocoder.reverse(request.long, request.lat))
      properties = address['properties']
      street_key = properties['x_strassenschluessel'][0][-5..]
      street = "#{properties['x_strassenname'][0]} (#{street_key} – #{properties['x_bereich'][0]})"
      housenumber, housenumber_addition = properties['x_hausnummer'][0].match(/\A(\d+)([A-Za-z]*)\z/).captures
    end

    request.service.document_url
           .gsub('{ks_id}', request.id.to_s)
           .gsub('{ks_user}', @user&.login || '')
           .gsub('{ks_str}', street)
           .gsub('{ks_hnr}', housenumber)
           .gsub('{ks_hnr_z}', housenumber_addition)
           .gsub('{ks_eigentuemer}', request.extended_attributes&.property_owner&.truncate(254, omission: '…') || '')
  end
end
