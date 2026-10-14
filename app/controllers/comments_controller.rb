# frozen_string_literal: true

class CommentsController < ApplicationController
  include RequestFeedback

  def new
    load_request
    @comment = Comment.new(service_request_id: @request.id, author: feedback_author, comment: nil,
      privacy_policy_accepted: nil)
    render_new_form
  end

  def create
    comment = Comment.create(params.expect(comment: %i[author comment])
      .merge(api_key: Comment.api_key, service_request_id: params[:request_id]).merge(privacy_policy_params))
    if comment.persisted?
      @redirect = request_redirect_path
      @success = I18n.t(:success_text, scope: "comments.#{context}.create")
    end
    render_create_result comment
  end
end
