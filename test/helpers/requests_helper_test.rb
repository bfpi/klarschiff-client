# frozen_string_literal: true

require 'test_helper'

class RequestsHelperTest < ActionView::TestCase
  DOCUMENT_URL = 'https://d3.example/?id={ks_id}&user={ks_user}&str={ks_str}&hnr={ks_hnr}&z={ks_hnr_z}&e={ks_eigentuemer}'
  USER = Struct.new(:login).new('max')
  ADDRESS = { objektgruppe: 'Adresse', strasse_name: 'Hauptstraße', strasse_schluessel: '0815',
              gemeindeteil_name: 'Mitte', hausnummer: '12', hausnummer_zusatz: 'a' }.freeze
  STREET = { objektgruppe: 'Straße', strasse_name: 'Nebenstraße', strasse_schluessel: '0816',
             gemeindeteil_name: 'Süd' }.freeze

  def document_request(property_owner: 'Hansestadt')
    Request.new(service_request_id: 53, lat: 54.1, long: 12.1,
      extended_attributes: { property_owner: property_owner }).tap do |req|
      req.define_singleton_method(:service) { Service.new(document_url: DOCUMENT_URL) }
    end
  end

  def document_url(features, message: 'OK', request: document_request)
    response = Struct.new(:message, :body).new(message, { features: features.map { { properties: it } } }.to_json)
    Net::HTTP.stub(:get_response, ->(uri) { (@uri = uri) && response }) do
      without_proxy { d3_document_url(request, USER) }
    end
  end

  def without_proxy
    proxies = ENV.to_h.slice('HTTP_PROXY', 'http_proxy')
    proxies.each_key { ENV.delete(it) }
    yield
  ensure
    ENV.update(proxies)
  end

  test 'd3_document_url uses the nearest address' do
    url = document_url([STREET, ADDRESS])

    assert_equal 'https://d3.example/?id=53&user=max&str=Hauptstraße (0815 – Mitte)&hnr=12&z=a&e=Hansestadt', url
  end

  test 'd3_document_url uses the nearest street without address' do
    url = document_url([STREET, STREET.merge(strasse_name: 'Weg')])

    assert_equal 'https://d3.example/?id=53&user=max&str=Nebenstraße (0816 – Süd)&hnr=&z=&e=Hansestadt', url
  end

  test 'd3_document_url marks the street as not assignable without results' do
    assert_includes document_url([]), "str=#{I18n.t(:not_assignable)}&hnr=&"
  end

  test 'd3_document_url marks the street as not assignable if the search fails' do
    assert_includes document_url([ADDRESS], message: 'Internal Server Error'), "str=#{I18n.t(:not_assignable)}&hnr=&"
  end

  test 'd3_document_url truncates the property owner' do
    url = document_url([], request: document_request(property_owner: 'x' * 300))

    assert_equal "e=#{'x' * 253}…", url[/e=.*\z/]
  end

  test 'd3_document_url searches the address around the request' do
    document_url([])

    assert_equal({ 'key' => Settings::AddressSearch.api_key, 'query' => '12.1,54.1', 'type' => 'reverse',
                   'class' => 'address', 'radius' => '100', 'in_epsg' => '4326' }, Rack::Utils.parse_query(@uri.query))
  end

  test 'statuses offers the permissable states and the current state' do
    request = Request.new(extended_attributes: { detailed_status: 'RECEIVED' })

    assert_equal [%w[offen RECEIVED], ['in Bearbeitung', 'IN_PROCESS'], %w[gelöst PROCESSED],
                  ['nicht lösbar', 'REJECTED']], statuses(request)
  end
end
