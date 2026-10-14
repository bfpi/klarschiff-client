# frozen_string_literal: true

class AreasController < ApplicationController
  def index
    respond_to do |format|
      format.html { head :not_acceptable }
      format.js { select_area }
      format.json { render json: Area.where(area_conditions) }
    end
  end

  private

  def select_area
    @context = params[:context]
    area_code = params[:area_code]
    geom = params[:geometry]
    if params[:from_form].present? && area_missing?(area_code, geom)
      @error = I18n.t("messages.errors.#{@context}_required")
      return render :index
    end
    return if (area_code || geom).blank?

    redirect_to "#{Settings::Url.ks_server_url}#{new_observation_path(area_code: area_code, geometry: geom)}"
  end

  def area_missing?(area_code, geom)
    (@context == 'districts' && area_code.blank?) || (@context == 'draw' && geom.blank?)
  end

  def area_conditions
    conditions = { area_code: Array.wrap(params[:area_code]).join(', '), limit: Settings::Client.observations_area_limit }
    %i[with_districts center].each { |key| conditions[key] = params[key] if params[key].present? }
    conditions.merge(region_conditions)
  end

  def region_conditions
    params[:region].present? ? { search_class: 'authority', regional_key: params[:region] } : {}
  end
end
