class AreasController < ApplicationController
  def index
    conds = {}
    conds.update area_code: Array.wrap(params[:area_code]).join(', ')
    conds.update with_districts: params[:with_districts] unless params[:with_districts].blank?
    @areas = Area.where(conds)
  end
end
