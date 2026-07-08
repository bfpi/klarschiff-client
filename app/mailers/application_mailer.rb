# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  prepend_view_path 'overlay/views'
end
