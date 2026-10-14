# frozen_string_literal: true

class NotesController < ApplicationController
  include RequestFeedback

  def new
    load_request
    @note = Note.new(service_request_id: @request.id, comment: nil)
    render_new_form
  end

  def create
    note = create_note
    @redirect = request_redirect_path if note.errors.blank?
    if note.errors.blank? && note.persisted?
      @success = I18n.t(:success_text, scope: 'notes.create')
    else
      @errors = note.errors
    end
    render "/application/#{context}/create"
  end

  private

  def create_note
    Note.create(params.expect(note: [:comment]).merge(
      service_request_id: params[:request_id], author: display?(:email) ? params[:author] : @user.email,
      api_key: Note.api_key
    ).merge(privacy_policy_params))
  rescue ActiveResource::ForbiddenAccess => e
    e.base_object_with_errors
  end
end
