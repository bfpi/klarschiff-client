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
      if Settings::Client.respond_to?(:also_archived) && Settings::Client.also_archived
        conditions.update(also_archived: true) unless params[:archive].blank?
      end
      @requests = Request.where(conditions.merge(radius: params[:radius])).try(:to_a)
      session[:referer_params] = params.slice(:controller, :action, :mobile, :ids)
    end
    respond_to do |format|
      format.html do
        @per_page = (params[:per_page].presence || 20).to_i
        @page = 1
        @requests.sort_by!(&:requested_datetime).reverse!
        @pages = (@requests.count / @per_page.to_f).ceil
        path = Rails.root.join('public/static/requests')
        FileUtils.rm_rf path
        FileUtils.mkdir_p path
        all_requests = @requests
        all_requests.each_slice(@per_page) do |requests|
          @requests = requests
          File.write path.join("#{@page}.html"), render_to_string
          @page += 1
        end
        return head :ok
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
    if params[:direct] || login_required?
      conditions = { service_request_id: id }
      if (states = Settings::Map.default_requests_states).present?
        conditions.update detailed_status: states
      end
      if Settings::Client.respond_to?(:also_archived) && Settings::Client.also_archived
        conditions[:also_archived] = true
      end
      return head(:not_found) unless @request = Request.where(conditions).first
      @direct = true
    else
      @request = Request.find(id)
      @mobile_popup = true if params[:mobile_popup]
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
        return new_mobile_request if @mobile
        if params[:switch_type]
          @type = params[:type]
        else
          @service = Service.find(service_code) if service_code
          @request = Request.new(type: @service&.type)
        end
        render "requests/#{ context }/new"
      end
      format.json do
        req = Request.new(position: params[:position])

        coord = Coordinate.new(req.lat, req.long)
        unless coord.redirect_url.blank?
          response.headers['X-Redirect-Url'] = coord.redirect_url
          return head :see_other
        end
        resp = { status: coord.covered_by_juristiction? ? 200 : 406 }
        if resp[:status] == 406
          req.errors.tap { |errors| errors.add :position, :outside }
          resp[:error] = req.errors.full_messages.first
        end
        render json: resp
      end
    end
  end

  def create
    return summary if params[:confirm] == 'true'
    if login_required?
      cookies[:last_type] = params[:request][:type]
      cookies[:last_service_code] = params[:request][:service_code].presence&.first
      cookies[:last_group] = Service.find(cookies[:last_service_code]).group if cookies[:last_service_code]
    end
    ids = []
    create_message = nil
    service = nil
    if (codes = params[:request][:service_code]).present?
      payload = permissable_params
      (codes = Array.wrap(codes).map(&:to_i).reject { |code| code == 0 }).each do |service_code|
        service ||= Service[service_code]
        result =
          begin
            Request.connection.post(
              Request.collection_path(nil, api_key: Request.api_key, email: display?(:email) ? params[:request][:email] : @user.email),
              Request.format.encode(
                payload.merge(service_code: service_code).merge(privacy_policy_params)
              )
            )
          rescue ActiveResource::ResourceInvalid => e
            e.base_object_with_errors
          end
        if result.is_a?(Net::HTTPCreated)
          req = Request.new.load(Request.format.decode(result.body))
          create_message = req.create_message
          ids << req.id
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
      @options = { id: ids.first, create_message: create_message } if context == 'desktop'
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

  def summary
    @request = Request.new(permissable_params)
    @service = Service.find(params[:request][:service_code][0])
    @request.service_code = params[:request][:service_code][0]
    media = params[:request][:media]
    if media.present?
      @media_type = media.content_type
      @media_size = media.size
      FileUtils.cp media.path, 'tmp/'
      @path = media.path.split('/').last
    end
    render 'requests/mobile/request_form'
  end
  
  def new_mobile_request
    if login_required?
      @request = Request.new(type: cookies[:last_type], category: cookies[:last_group],
                             service_code: Array.wrap(cookies[:last_service_code]))
    else
      @service = Service.find(service_code) if service_code
      @request = Request.new(type: @service&.type)
    end
    if (pos = params[:position]).present?
      @request.lat = pos[1]
      @request.long = pos[0]
      unless (@coord = Coordinate.new(@request.lat, @request.long)).covered_by_juristiction?
        @errors = Request.new.errors.tap { |errors| errors.add :position, :outside }
        @modal_title_options = { count: 1 }
        return render :outside
      end
    end
    if params[:switch_type]
      @type = params[:type]
      return render 'requests/mobile/new'
    end
    return render 'requests/mobile/new_position' if params[:position].blank?
    render 'requests/mobile/new'
  end

  def permissable_params
    keys = [:service_code, :description, :email, :privacy_policy_accepted]
    keys += [:detailed_status, :job_status] if action_name == 'update'
    keys |= [:lat, :long] if ['create', 'new', 'update'].include?(action_name)
    data = params.require(:request).permit(keys)
    if (img = params[:request][:media]).present?
      if img.is_a? String
        File.open("tmp/#{img}", 'rb') { |file| data[:media] =  Base64.encode64(file.read) }
        FileUtils.rm "tmp/#{img}"
      else
        data[:media] = Base64.encode64(img.tempfile.read)
      end
    end
    data
  end
end
