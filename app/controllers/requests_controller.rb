class RequestsController < ApplicationController
  def index
    unless @back = params[:back]
      conditions = login_required? ? { agency_responsible: @user.field_service_team, negation: "agency_responsible" } : {}
      conditions.update service_code: service_code if service_code
      conditions[:service_request_id] = params[:ids].join(",") if params[:ids]
      conditions[:area_code] = params[:area] if params[:area]
      conditions[:start_date] = I18n.l(DateTime.parse(params[:start_date]), format: :citysdk) if params[:start_date]
      conditions[:service_code] = params[:service_code] if params[:service_code]
      if (center = params[:center]).present?
        conditions.update lat: center[0], long: center[1]
      end
      conditions.update(keyword: params[:typ].select(&:presence).join(', ')) unless @mobile || params[:typ].nil?
      if (states = Settings::Map.default_requests_states).present?
        if @mobile || params[:status].nil?
          conditions.update detailed_status: states
        else
          conditions.update(detailed_status: (states = params[:status].select(&:presence)).join(', '))
          conditions.update(status: '') if states.blank?
        end
      end
      @requests = Request.where(conditions.merge(radius: params[:radius])).try(:to_a)
      session[:referer_params] = params.slice(:controller, :action, :mobile,:ids)
    end
    respond_to do |format|
      format.html do
        return head :not_acceptable if params[:page].blank? || params[:per_page].blank? || params[:pages].blank?
        @page = params[:page].to_i
        @per_page = params[:per_page].to_i
        @pages = params[:pages].to_i

        indexStart = ((@page - 1) * @per_page);
        @requests = @requests.slice(indexStart, @per_page)
        render :layout => false
      end
      format.js do
        if @mobile
          render "/requests/mobile/index"
        else
          @back ? render('/requests/desktop/index') :
            redirect_to("#{ Settings::Url.ks_server_url }#{ request_path(@requests.first,
                        id_list: @requests.map(&:id), refresh: params[:refresh], mobile: @mobile) }")
        end
      end
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
    @photo = Photo.new(service_request_id: @request.id, author: nil)
    @refresh = params[:refresh].presence
    @id_list = params[:id_list].try(:map, &:to_i).presence
    render "/requests/#{ context }/show"
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
      @redirect = request_path(id, id_list: params[:request][:id_list], mobile: @mobile).html_safe
      @success = I18n.t('messages.success.request_update')
    else
      @errors = result.errors
      @modal_title_options = { count: 1 }
    end
  end

  def new
    respond_to do |format|
      format.html { head(:forbidden) }
      format.js do
        if params[:switch_type]
          @type = params[:type]
        elsif @mobile
          @request = Request.new(type: params[:type], position: params[:position])
          unless @request.try(:lat).present? && @request.try(:long).present?
            return render "requests/#{ context }/new_position"
          end
          unless Coordinate.new(@request.lat, @request.long).covered_by_juristiction?
            @errors = Request.new.errors.tap { |errors| errors.add :position, :outside }
            @redirect = new_request_path(type: @request.type)
            if @mobile
              @modal_title_options = { count: 1 }
              return render :outside
            else
              return render "requests/#{ context }/new_position"
            end
          end
        else
          @service = Service.find(service_code) if service_code
          @request = Request.new(type: @service&.type)
        end
        render "requests/#{ context }/new"
      end
      format.json do
        req = Request.new(position: params[:position])
        resp = { status: Coordinate.new(req.lat, req.long).covered_by_juristiction? ? 200 : 406 }
        if resp[:status] == 406
          req.errors.tap { |errors| errors.add :position, :outside }
          resp[:error] = req.errors.full_messages.first
        end
        render json: resp
      end
    end
  end

  def create
    ids = []
    service = nil
    if (codes = params[:request][:service_code]).present?
      payload = permissable_params
      (codes = Array.wrap(codes).map(&:to_i).reject { |code| code == 0 }).each do |service_code|
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
      if @mobile
        @errors = Request.new.errors.tap { |errors| errors.add :service_code, :blank }
      else
        @errors = Request.new.errors.tap { |errors| errors.add :base, :service_code_required }
      end
      @modal_title_options = { count: 1 }
    end
    if ids.present? && !service.nil?
      @options = { id: ids.first } if context == 'desktop'
      @redirect = requests_path(ids: ids, refresh: true, mobile: @mobile) unless context == 'desktop'
      @modal_title_options = { count: ids.size } if @errors.blank?
      @success = I18n.t('messages.success.request_create', count: ids.size,
                        type: I18n.t(service.type, scope: 'service.types', count: ids.size))
    end
    if context == 'desktop' && @errors.present?
      @errors = Array.wrap(@errors).map(&:messages)
      return render 'requests/desktop/new'
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
    render "/application/#{ context }/create"
  end

  private
  def permissable_params
    keys = [:service_code, :description, :email]
    keys += [:detailed_status, :job_status] if action_name == 'update'
    keys |= [:lat, :long] if ['create', 'update'].include?(action_name)
    data = params.require(:request).permit(keys)
    if (img = params[:request][:media]).present?
      data[:media] = Base64.encode64(img.read)
    end
    data
  end
end
