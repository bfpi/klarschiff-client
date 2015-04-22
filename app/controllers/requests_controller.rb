class RequestsController < ApplicationController
  def index
    conditions = { agency_responsible: @user.field_service_team, negation: "agency_responsible" }
    conditions[:service_request_id] = params[:ids].join(",") if params[:ids]
    if (center = params[:center]).present?
      conditions.update lat: center[0], long: center[1]
    end
    conditions[:radius] = params[:radius] if params[:radius]
    @requests = Request.where(conditions).try(:to_a)
    session[:list] = params
    session[:id_list] = @requests.map &:id
    respond_to do |format|
      format.html { head :not_acceptable }
      format.js
      format.json { render json: @requests }
    end
  end

  def show
    return head(:not_found) unless (id = params[:id]).present?
    @request = Request.find(id)
  end

  def edit
    return head(:not_found) unless (id = params[:id]).present?
    @request = Request.find(id)
  end

  def update
    return head(:not_found) unless (id = params[:id]).present?
    result = Request.patch(id, { api_key: Request.api_key, email: @user.email },
                           Request.format.encode(permissable_params))
    if result.is_a?(Net::HTTPOK)
      @redirect = request_path(id)
      @success = I18n.t('messages.success.request_update')
    else
      @errors = result.errors
    end
  end

  def new
    @request = Request.new(params.permit(:type, position: []))
    unless @request.try(:lat).present? && @request.try(:long).present?
      return render :new_position
    end
  end

  def create
    result = Request.connection.post(
      Request.collection_path(nil, api_key: Request.api_key, email: @user.email),
      Request.format.encode(permissable_params))
    if result.is_a?(Net::HTTPCreated)
      request = Request.find(Request.new.load(Request.format.decode(result.body)).id)
      @redirect = request_path(request)
      @success = I18n.t('messages.success.request_create', 
                        type: I18n.t(request.service.type, scope: 'service.types'))
    else
      @errors = result.errors
    end
  end

  private
  def permissable_params
    keys = [:service_code, :title, :description]
    keys << :detailed_status if action_name == 'update'
    keys |= [:lat, :long] if action_name == 'create'
    data = params.require(:request).permit(keys)
    if (img = params[:request][:media]).present?
      data[:media] = Base64.encode64(img.read)
    end
    data
  end
end
