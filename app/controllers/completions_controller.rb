# frozen_string_literal: true

class CompletionsController < ApplicationController
  before_action { head :forbidden unless request.format.js? }

  def new
    @request = Request.find(params[:request_id])
    @completion = Completion.new(service_request_id: @request.id, author: login_required? ? @user.email : nil,
      comment: nil, privacy_policy_accepted: nil)
    @id_list = params[:id_list].try(:map, &:to_i).presence
    render "/application/#{context}/new"
  end

  def create
    completion = Completion.create(permitted_completion_params)
    set_redirect_path
    @errors = completion.errors unless completion.persisted?
    return render "application/#{context}/create" unless context.desktop? && @errors.present?
    @errors = Array.wrap(@errors).map(&:messages)
    render 'application/desktop/new'
  end

  private

  def permitted_completion_params
    params.require(:completion).permit(:author, :comment).merge(
      service_request_id: params[:request_id],
      privacy_policy_accepted: params[:completion][:privacy_policy_accepted].present?
    )
  end

  def set_redirect_path
    @redirect = request_path(params[:request_id], id_list: params[:completion][:id_list], mobile: @mobile).html_safe
  end
end
