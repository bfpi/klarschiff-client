# frozen_string_literal: true

class RequestsController < ApplicationController
  include Requests::Creation
  include Requests::NewForm
  include Requests::StaticPages

  def index
    @requests = load_requests unless (@back = params[:back])
    respond_to do |format|
      format.html { write_static_pages }
      format.js { render_index }
      format.json { render json: @requests }
    end
  end

  def show
    return head(:not_found) if (id = params[:id]).blank?
    return head(:not_found) unless (@request = find_request(id))

    @photo = Photo.new(service_request_id: @request.id, author: nil)
    @refresh = params[:refresh].presence
    @id_list = id_list_param
    render "/requests/#{context}/show"
  end

  def new
    respond_to do |format|
      format.html { head(:forbidden) }
      format.js { @mobile ? new_mobile_request : new_desktop_request }
      format.json { check_position }
    end
  end

  def edit
    return head(:not_found) if (id = params[:id]).blank?

    @request = Request.find(id)
    @id_list = id_list_param
  end

  def create
    return summary if params[:confirm] == 'true'

    create_requests
    return render_new_with_errors if context.desktop? && @errors.present?

    render "/application/#{context}/create"
  end

  def update
    return head(:not_found) if (id = params[:id]).blank?

    result = patch_request(id)
    if result.is_a?(Net::HTTPOK)
      @redirect = request_path(id, id_list: params[:request][:id_list], mobile: @mobile)
      @success = I18n.t('messages.success.request_update')
    else
      @errors = result.errors
      @modal_title_options = { count: 1 }
    end
  end

  private

  def load_requests
    session[:referer_params] = params.slice(:controller, :action, :mobile, :ids)
    filter = RequestFilter.new(params, mobile: @mobile, user: (@user if login_required?), service_code: service_code)
    Request.where(filter.conditions).try(:to_a)
  end

  def render_index
    return render('/requests/mobile/index') if @mobile
    return render('/requests/desktop/index') if @back

    path = request_path(@requests.first, id_list: @requests.map(&:id), refresh: params[:refresh], mobile: @mobile)
    redirect_to "#{Settings::Url.ks_server_url}#{path}"
  end

  def find_request(id)
    if params[:direct] || login_required?
      @direct = true
      Request.where(RequestFilter.single(id)).first
    else
      @mobile_popup = true if params[:mobile_popup]
      Request.find(id)
    end
  end

  def patch_request(id)
    Request.patch(id, { api_key: Request.api_key, email: request_email }, Request.format.encode(permissable_params))
  rescue ActiveResource::ResourceInvalid, ActiveResource::ForbiddenAccess => e
    e.base_object_with_errors
  end

  def request_email
    display?(:email) ? params[:request][:email] : @user.email
  end

  def permissable_params
    data = params.expect(request: request_keys)
    data[:media] = encode_media(params[:request][:media]) if params[:request][:media].present?
    data
  end

  def request_keys
    keys = %i[service_code description email privacy_policy_accepted]
    keys += %i[detailed_status job_status] if action_name == 'update'
    keys |= %i[lat long] if %w[create new update].include?(action_name)
    keys
  end

  # Images uploaded in the summary of the mobile form are referenced by their file name
  def encode_media(media)
    media.is_a?(String) ? encode_file_from_path(media) : Base64.encode64(media.tempfile.read)
  end

  def encode_file_from_path(filename)
    safe_path = Rails.root.join('tmp', File.basename(filename))
    Base64.encode64(File.read(safe_path))
  ensure
    FileUtils.rm_f(safe_path)
  end
end
