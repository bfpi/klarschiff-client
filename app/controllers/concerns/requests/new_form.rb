# frozen_string_literal: true

module Requests
  # Steps of the form for a new request: position, type and summary before saving
  module NewForm
    extend ActiveSupport::Concern

    private

    def new_desktop_request
      if params[:switch_type]
        @type = params[:type]
      else
        @service = Service.find(service_code) if service_code
        @request = Request.new(type: @service&.type)
      end
      render "requests/#{context}/new"
    end

    def new_mobile_request
      @request = new_mobile_request_defaults
      locate_new_request(params[:position]) if params[:position].present?
      return render_outside if @coord && !@coord.covered_by_juristiction?

      @type = params[:type] if params[:switch_type]
      render new_mobile_template
    end

    # Without position it is chosen first, unless only the type is switched
    def new_mobile_template
      params[:position].blank? && !params[:switch_type] ? 'requests/mobile/new_position' : 'requests/mobile/new'
    end

    # Field service teams start with the service of their last request
    def new_mobile_request_defaults
      if login_required?
        return Request.new(type: cookies[:last_type], category: cookies[:last_group],
          service_code: Array.wrap(cookies[:last_service_code]))
      end
      @service = Service.find(service_code) if service_code
      Request.new(type: @service&.type)
    end

    def locate_new_request(position)
      @request.lat = position[1]
      @request.long = position[0]
      @coord = Coordinate.new(@request.lat, @request.long)
    end

    def render_outside
      @errors = outside_errors
      @modal_title_options = { count: 1 }
      render :outside
    end

    def check_position
      req = Request.new(position: params[:position])
      coord = Coordinate.new(req.lat, req.long)
      return redirect_to_instance(coord.redirect_url) if coord.redirect_url.present?
      return render(json: { status: 200 }) if coord.covered_by_juristiction?

      render json: { status: 406, error: outside_errors.full_messages.first }
    end

    # Another instance of Klarschiff is responsible for the position
    def redirect_to_instance(url)
      response.headers['X-Redirect-Url'] = url
      head :see_other
    end

    def outside_errors
      Request.new.errors.tap { |errors| errors.add :position, :outside }
    end

    def summary
      @request = Request.new(permissable_params)
      @request.service_code = params.expect(request: [{ service_code: [] }])[:service_code].first
      @service = Service.find(@request.service_code)
      cache_media(params[:request][:media])
      render 'requests/mobile/request_form'
    end

    # Keeps an uploaded image until the request is saved, see RequestsController#encode_media
    def cache_media(media)
      return if media.blank?

      @media_type = media.content_type
      @media_size = media.size
      FileUtils.cp media.path, 'tmp/'
      @path = media.path.split('/').last
    end
  end
end
