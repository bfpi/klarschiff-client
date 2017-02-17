class AreasController < ApplicationController
  def index
    unless (@show_districts = params[:show_districts] || @cancel = params[:cancel]).present?
      conds = {}
      conds.update area_code: Array.wrap(params[:area_code]).join(', ')
      conds.update with_districts: params[:with_districts] unless params[:with_districts].blank?
      @areas = Area.where(conds)
    end
    respond_to do |format|
      format.html { head :not_acceptable }
      format.js
      format.json { render json: @areas }
    end
  end
end
