class AreasController < ApplicationController
  def index
    respond_to do |format|
      format.html { head :not_acceptable }
      format.js do
        @context = params[:context]
        area_code = params[:area_code]
        geom = params[:geometry]
        if params[:from_form].present?
          if (@context == 'districts' && area_code.blank?) || (@context == 'draw' && geom.blank?)
            @error = I18n.t("messages.errors.#{ @context }_required")
            return render :index
          end
        end
        redirect_to "#{ Settings::Url.ks_server_url }#{ new_observation_path(area_code: area_code, geometry: geom) }" if (area_code || geom).present?
      end
      format.json do
        conds = {}
        conds.update area_code: Array.wrap(params[:area_code]).join(', ')
        conds.update with_districts: params[:with_districts] unless params[:with_districts].blank?
        conds.update center: params[:center] unless params[:center].blank?
        conds.update limit: Settings::Client.observations_area_limit
        areas = Area.where(conds)
        render json: areas
      end
    end
  end
end
