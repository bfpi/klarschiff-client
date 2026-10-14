# frozen_string_literal: true

class VotesController < ApplicationController
  include RequestFeedback

  def new
    load_request
    @vote = Vote.new(service_request_id: @request.id, author: feedback_author, privacy_policy_accepted: nil,
      status_updates_for_supporter: nil)
    render_new_form
  end

  def create
    vote = Vote.create(vote_params)
    @redirect = request_redirect_path
    render_create_result vote
  end

  private

  def vote_params
    params.expect(vote: [:author]).merge(
      service_request_id: params[:request_id],
      status_updates_for_supporter: params[:vote][:status_updates_for_supporter].present?
    ).merge(privacy_policy_params)
  end
end
