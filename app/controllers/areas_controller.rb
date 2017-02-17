class AreasController < ApplicationController
  def index
    unless (@show_districts = params[:show_districts] || @cancel = params[:cancel]).present?
    end
    respond_to do |format|
      format.html { head :not_acceptable }
      format.js do
        if params[:area_code].present?
          redirect_to [:new, :observation, area_code: params[:area_code]]
        end
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
