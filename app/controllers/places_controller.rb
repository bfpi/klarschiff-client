# frozen_string_literal: true

require 'open-uri'

class PlacesController < ApplicationController
  def index
    @pattern = remember_pattern
    @places = request_places + address_places if @pattern.present?
    respond_to do |format|
      format.html { head(:not_acceptable) }
      format.js { render "/places/#{context}/#{params[:auto] ? 'auto' : 'index'}" }
      format.json { render json: @places.to_json }
    end
  end

  private

  def remember_pattern
    return session[:places_filter] if params[:pattern].nil?

    session[:places_filter] = params[:pattern]
  end

  # Requests can be found by their number
  def request_places
    return [] unless Settings::AddressSearch.search_request_id_enabled && (number = @pattern[/^(\d*)$/, 1])

    Request.where(detailed_status: Settings::Map.default_requests_states, service_request_id: number).try(:to_a)
           .map { |req| request_place(req) }
  end

  def request_place(req)
    Place.new('geometry' => { 'coordinates' => [req.long, req.lat], 'type' => 'Point', 'transform_bbox' => true },
      'properties' => { '_title_' => "Meldung ##{req.service_request_id}", 'feature_id' => req.service_request_id },
      'type' => 'Feature')
  end

  def address_places
    response = address_search_uri.open(address_search_options)
    return [] unless response&.status&.include?('OK')

    Array.wrap(JSON.parse(response.read).try(:[], 'features')).map { |feature| Place.new(feature) }
  rescue OpenURI::HTTPError => e
    log_address_search_error(e)
    []
  end

  def log_address_search_error(error)
    Rails.logger.error "Geocodr Error: #{error.inspect}, #{error.message}\n"
    Rails.logger.error error.backtrace.join("\n  ")
  end

  def address_search_uri
    URI.parse(Settings::AddressSearch.url).tap do |uri|
      uri.query = URI.encode_www_form(key: Settings::AddressSearch.api_key, query: address_query, type: 'search',
        class: 'address', shape: 'bbox', out_epsg: '3857', limit: '5')
    end
  end

  def address_query
    [Settings::AddressSearch.localisator.presence, @pattern].compact.join(' ')
  end

  def address_search_options
    options = { ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE }
    if Settings::AddressSearch.respond_to?(:proxy) && Settings::AddressSearch.proxy.present?
      options[:proxy] = URI.parse(Settings::AddressSearch.proxy)
    end
    options
  end
end
