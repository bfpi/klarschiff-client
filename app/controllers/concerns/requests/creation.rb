# frozen_string_literal: true

module Requests
  # Creates a request for each selected service and prepares the result for the views
  module Creation
    extend ActiveSupport::Concern

    private

    def create_requests
      remember_last_service if login_required?
      params[:request][:service_code].present? ? submit_requests : reject_missing_service_code
    end

    def remember_last_service
      service_code = params[:request][:service_code].presence&.first
      cookies[:last_type] = params[:request][:type]
      cookies[:last_service_code] = service_code
      cookies[:last_group] = Service.find(service_code).group if service_code
    end

    def submit_requests
      submission = submit_service_requests
      @errors = submission.errors.presence
      show_created_requests(submission) if submission.ids.present? && submission.service
      @modal_title_options ||= { count: service_codes.size }
      @errors = submission.merged_errors if @errors && context.mobile?
    end

    def submit_service_requests
      RequestSubmission.new(permissable_params.merge(privacy_policy_params), email: request_email)
                       .submit(service_codes)
    end

    def service_codes
      Array.wrap(params[:request][:service_code]).map(&:to_i).reject(&:zero?)
    end

    def show_created_requests(submission)
      count = submission.ids.size
      if context.desktop?
        @options = { id: submission.ids.first, create_message: submission.create_message }
      else
        @redirect = requests_path(ids: submission.ids, refresh: true, mobile: @mobile)
      end
      @modal_title_options = { count: count } if @errors.blank?
      @success = I18n.t('messages.success.request_create', count: count,
        type: I18n.t(submission.service.type, scope: 'service.types', count: count))
    end

    def reject_missing_service_code
      @errors = Request.new.errors.tap do |errors|
        @mobile ? errors.add(:service_code, :blank) : errors.add(:base, :service_code_required)
      end
      @modal_title_options = { count: 1 }
    end

    def render_new_with_errors
      @errors = Array.wrap(@errors).map(&:messages)
      render 'requests/desktop/new'
    end
  end
end
