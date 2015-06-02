class PlacesController < ApplicationController
  def index
    respond_to do |format|
      format.html { head(:not_acceptable) }
      format.js do
        if (@pattern = params[:pattern]).present?
          session[:places_filter] = @pattern
        else
          @pattern = session[:places_filter]
        end
        if @pattern.blank?
          return head(:ok) if params[:pattern]
        else
          require 'open-uri'
          uri = URI(Settings::Url.ks_frontend_search_url)
          uri.query = URI.encode_www_form(searchtext: @pattern)

          if (res = open(uri)) && res.status.include?('OK')
            @places = Array.wrap(JSON.parse(res.read).try(:[], 'array')).map do |p|
              Place.new p
            end
          end
        end
      end
    end
  end
end
