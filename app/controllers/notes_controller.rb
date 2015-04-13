class NotesController < ApplicationController
  def new
    @request = Request.find(params[:request_id])
    @note = Note.new(service_request_id: @request.id, comment: nil)
    respond_to do |format|
      format.html { head :forbidden }
      format.js
    end
  end

  def create
    note = Note.create(params.require(:note).permit(:comment).merge(
      service_request_id: params[:request_id], author: @user.email,
      api_key: Note.api_key))
    @redirect = request_url(params[:request_id])
    if note.persisted?
      @success = I18n.t(:success_text, scope: 'notes.create')
    else
      @errors = note.errors
    end
  end
end
