# frozen_string_literal: true

module ClientConfig
  extend ActiveSupport::Concern

  included do
    helper_method :display?, :login_required?, :service_code, :multi_requests_enabled?, :max_image_size,
                  :max_upload_files
  end

  def display?(par, req = nil)
    return display_completions?(req) if par == :completions

    Settings::Client.send("show_#{par}")
  end

  def service_code
    !@mobile && Settings::Client.service_code
  end

  def login_required?
    Settings::Client.login_required
  end

  def multi_requests_enabled?
    Settings::Client.multi_requests_enabled
  end

  def max_image_size
    Settings::Client.max_image_size
  end

  def max_upload_files
    Settings::Client.respond_to?(:max_upload_files) ? Settings::Client.max_upload_files.to_s.to_i : 0
  end

  private

  def display_completions?(req)
    Settings::Client.show_completions && req&.status&.in?(%w[received reviewed in_process])
  end
end
