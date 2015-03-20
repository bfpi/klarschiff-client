class PlacesController < ApplicationController
  def index
    require 'open-uri'
    if (@pattern ||= params[:pattern]).present?
      uri = URI(KS_FRONTEND_SEARCH_URL)
      uri.query = URI.encode_www_form(searchtext: @pattern)

      if (res = open(uri)) && res.status.include?('OK')
        @places = Array.wrap(JSON.parse(res.read).try(:[], 'array')).map do |p|
          Place.new p
        end
      end
    end
    respond_to do |format|
      format.html { head :forbidden }
      format.js
    end
  end
end
