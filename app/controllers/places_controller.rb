class PlacesController < ApplicationController
  def index
    require 'open-uri'
    pattern = 'tischbein'
    if (pattern ||= params[:pattern]).present?
      uri = URI(KS_FRONTEND_SEARCH_URL)
      uri.query = URI.encode_www_form(searchtext: pattern)

      if (res = open(uri)) && res.status.include?('OK')
        @places = Array.wrap(JSON.parse(res.read).try(:[], 'array')).map do |p|
          Place.new p
        end
      end
    end
    logger.info @places.inspect
    #head :ok
  end
end
