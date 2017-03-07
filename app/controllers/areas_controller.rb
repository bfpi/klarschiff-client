class AreasController < ApplicationController
  def index
    respond_to do |format|
      format.html { head :not_acceptable }
      format.js do
        @context = params[:context]
        area_code = params[:area_code]
        geom = params[:geometry]
        redirect_to "#{ Settings::Url.ks_server_url }#{ new_observation_path(area_code: area_code, geometry: geom) }" if (area_code || geom).present?
      end
      format.json do
        conds = {}
        conds.update area_code: Array.wrap(params[:area_code]).join(', ')
        conds.update with_districts: params[:with_districts] unless params[:with_districts].blank?
        areas = Area.where(conds)
        render json: areas
      end
    end
  end
end
