require 'open-uri'

class PlacesController < ApplicationController
  def index
    if (@pattern = params[:pattern]).nil?
      @pattern = session[:places_filter]
    else
      session[:places_filter] = @pattern
    end
    if @pattern.present?
      @places = []
      if Settings::Geocodr.search_request_id_enabled && @pattern =~ /^(\d*)$/
        Request.where(
          detailed_status: Settings::Map.default_requests_states,
          service_request_id: ::Regexp.last_match(1)
        ).try(:to_a).map do |p|
          @places << Place.new({ 'geometry' => { 'coordinates' => [p.long, p.lat], 'type' => 'Point', 'transform_bbox' => true },
                                 'properties' => { '_title_' => "Meldung ##{p.service_request_id}",
                                                   'feature_id' => p.service_request_id },
                                 'type' => 'Feature' })
        end
      end

      Geocodr.search_places(@pattern).each do |place|
        @places << place
      end
    end

    respond_to do |format|
      format.html { head(:not_acceptable) }
      format.js do
        if params[:auto]
          render "/places/#{context}/auto" # render partial: "/places/mobile/results"
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
