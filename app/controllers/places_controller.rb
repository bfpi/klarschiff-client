class PlacesController < ApplicationController
  def index
    unless (@pattern = params[:pattern]).nil?
      session[:places_filter] = @pattern
    else
      @pattern = session[:places_filter]
    end
    unless @pattern.blank?
      @places = []
      if Settings::AddressSearch.search_request_id_enabled && @pattern =~ /^(\d*)$/
        Request.where(
            detailed_status: Settings::Map.default_requests_states,
            service_request_id: $1).try(:to_a).map do |p|
          @places << Place.new({ "geometry"=>{"coordinates"=>[p.long, p.lat], "type"=>"Point", "transform_bbox" => true},
                      "properties"=>{ "_title_"=>"Meldung ##{ p.service_request_id }" },
                      "type"=>"Feature" })
        end
      end

      require 'open-uri'
      uri = URI(Settings::AddressSearch.url)
      if !(localisator = Settings::AddressSearch.localisator).blank?
        query = Settings::AddressSearch.localisator + ' ' + @pattern
      else
        query = @pattern
      end
      uri.query = URI.encode_www_form(key: Settings::AddressSearch.api_key, query: query, type: 'search', class: 'address', shape: 'bbox', limit: '5')
      
      if (res = open(uri, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)) && res.status.include?('OK')
        Array.wrap(JSON.parse(res.read).try(:[], 'features')).map do |p|
          @places << Place.new(p)
        end
      end
    end

    respond_to do |format|
      format.html { head(:not_acceptable) }
      format.js do
        if params[:auto]
          render "/places/#{context}/auto" #render partial: "/places/mobile/results"
        else
          render "/places/#{context}/index"
        end
      end
      format.json do
        render json: @places.to_json
      end
    end
  end
end
