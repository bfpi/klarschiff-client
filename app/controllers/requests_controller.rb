class RequestsController < ApplicationController
  def index
    conditions = login_required? ? { agency_responsible: @user.field_service_team, negation: "agency_responsible" } : {}
    conditions[:service_request_id] = params[:ids].join(",") if params[:ids]
    if (center = params[:center]).present?
      conditions.update lat: center[0], long: center[1]
    end
    if (states = Settings::Map.default_requests_states).present?
      conditions.update detailed_status: states
    end
    @requests = Request.where(conditions.merge(radius: params[:radius])).try(:to_a)
    session[:referer_params] = params.slice(:controller, :action, :ids)
    respond_to do |format|
      format.html { head :not_acceptable }
      format.js
      format.json { render json: @requests }
    end
  end

  def show
    return head(:not_found) unless (id = params[:id]).present?
    if params[:direct]
      conditions = { service_request_id: id }
      if (states = Settings::Map.default_requests_states).present?
        conditions.update detailed_status: states
      end
      return head(:not_found) unless @request = Request.where(conditions).first
      @direct = true
    else
      @request = Request.find(id)
    end
    @id_list = params[:id_list].try(:map, &:to_i).presence
  end

  def edit
    return head(:not_found) unless (id = params[:id]).present?
    @request = Request.find(id)
    @id_list = params[:id_list].try(:map, &:to_i).presence
  end

  def update
    return head(:not_found) unless (id = params[:id]).present?
    result =
      begin
        Request.patch(id, { api_key: Request.api_key, email: display?(:email) ? params[:request][:email] : @user.email },
                      Request.format.encode(permissable_params))
      rescue ActiveResource::ResourceInvalid, ActiveResource::ForbiddenAccess => e
        e.base_object_with_errors
      end
    if result.is_a?(Net::HTTPOK)
      @redirect = request_path(id, id_list: params[:request][:id_list]).html_safe
      @success = I18n.t('messages.success.request_update')
    else
      @errors = result.errors
      @modal_title_options = { count: 1 }
    end
  end

  def new
    @request = Request.new(type: params[:type], position: params[:position])
    @mobile = params[:mobile].presence
    unless @request.try(:lat).present? && @request.try(:long).present?
      return render "requests/#{ context }/new_position"
    end
    unless Coordinate.new(@request.lat, @request.long).covered_by_juristiction?
      @errors = Request.new.errors.tap { |errors| errors.add :position, :outside }
      @redirect = new_request_path(type: @request.type)
      return render :outside
    end
    render "requests/#{ context }/new"
  end

  def create
    ids = []
    service = nil
    if (codes = params[:request][:service_code]).present?
      payload = permissable_params
      (codes = codes.map(&:to_i).reject { |code| code == 0 }).each do |service_code|
        service ||= Service[service_code]
        result =
          begin
            Request.connection.post(
              Request.collection_path(nil, api_key: Request.api_key, email: display?(:email) ? params[:request][:email] :  @user.email),
              Request.format.encode(payload.merge(service_code: service_code)))
          rescue ActiveResource::ResourceInvalid => e
            e.base_object_with_errors
          end
        if result.is_a?(Net::HTTPCreated)
          ids << Request.new.load(Request.format.decode(result.body)).id
        else
          (@errors ||= []) << result.errors
          break unless ids.present?
        end
      end
    else
      @errors = Request.new.errors.tap { |errors| errors.add :service_code, :blank }
      @modal_title_options = { count: 1 }
    end
    if ids.present? && !service.nil?
      @redirect = requests_path(ids: ids)
      @modal_title_options = { count: ids.size } if @errors.blank?
      @success = I18n.t('messages.success.request_create', count: ids.size,
                        type: I18n.t(service.type, scope: 'service.types', count: ids.size))
    end
    @modal_title_options ||= { count: codes.size }
    if (errors = @errors.try(:dup)).is_a? Array
      @errors = Request.new.errors.tap { |e|
        errors.map(&:messages).each do |messages|
          messages.each do |key, values|
            values.uniq.each do |message|
              e.add(key, message) unless e.added? key, message
            end
          end
        end
      }
    end
  end

  private
  def permissable_params
    keys = [:service_code, :description, :email]
    keys += [:detailed_status, :job_status] if action_name == 'update'
    keys |= [:lat, :long] if action_name == 'create'
    data = params.require(:request).permit(keys)
    if (img = params[:request][:media]).present?
      data[:media] = Base64.encode64(img.read)
    end
    data
  end
end
