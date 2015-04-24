class RequestsController < ApplicationController
  def index
    conditions = { agency_responsible: @user.field_service_team, negation: "agency_responsible" }
    conditions[:service_request_id] = params[:ids].join(",") if params[:ids]
    if (center = params[:center]).present?
      conditions.update lat: center[0], long: center[1]
    end
    @requests = Request.where(conditions.merge(params.slice(:radius))).try(:to_a)
    session[:referer_params] = params.slice(:controller, :action, :ids)
    session[:id_list] = @requests.map(&:id) if params[:ids]
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
      @modal_title_options = { count: 1 }
    end
  end

  def new
    @request = Request.new(params.permit(:type, position: []))
    unless @request.try(:lat).present? && @request.try(:long).present?
      return render :new_position
    end
  end

  def create
    ids = []
    if (codes = params[:request][:service_code]).present?
      (codes = codes.map(&:to_i).reject { |code| code == 0 }).each do |service_code|
        result = Request.connection.post(
          Request.collection_path(nil, api_key: Request.api_key, email: @user.email),
          Request.format.encode(permissable_params))
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
    if ids.present?
      @redirect = requests_path(id: ids)
      @modal_title_options = { count: ids.size } if @errors.blank?
      @success = I18n.t('messages.success.request_create', count: ids.size,
                        type: I18n.t(request.service.type, scope: 'service.types', count: ids.size))
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
