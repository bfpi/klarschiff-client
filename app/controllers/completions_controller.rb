# frozen_string_literal: true

class CompletionsController < ApplicationController
  include RequestFeedback

  before_action { head :forbidden unless request.format.js? }

  def new
    load_request
    @completion = Completion.new(service_request_id: @request.id, author: feedback_author, comment: nil,
      privacy_policy_accepted: nil)
    render_new_form
  end

  def create
    completion = Completion.create(params.expect(completion: %i[author comment])
      .merge(service_request_id: params[:request_id]).merge(privacy_policy_params))
    @redirect = request_redirect_path
    render_create_result completion
  end
end
