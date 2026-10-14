# frozen_string_literal: true

class AbusesController < ApplicationController
  include RequestFeedback

  def new
    load_request
    @abuse = Abuse.new(service_request_id: @request.id, author: feedback_author, comment: nil,
      privacy_policy_accepted: nil)
    render_new_form
  end

  def create
    abuse = Abuse.create(params.expect(abuse: %i[author comment])
      .merge(service_request_id: params[:request_id]).merge(privacy_policy_params))
    @redirect = request_redirect_path
    render_create_result abuse
  end
end
