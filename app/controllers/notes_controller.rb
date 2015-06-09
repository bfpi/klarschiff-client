class NotesController < ApplicationController
  def new
    @request = Request.find(params[:request_id])
    @note = Note.new(service_request_id: @request.id, comment: nil)
    @id_list = params[:id_list].try(:map, &:to_i).presence
    respond_to do |format|
      format.html { head :forbidden }
      format.js
    end
  end

  def create
    note = Note.create(params.require(:note).permit(:comment).merge(
      service_request_id: params[:request_id], author: @user.email,
      api_key: Note.api_key))
    @redirect = request_path(params[:request_id], id_list: params[:note][:id_list]).html_safe
    if note.persisted?
      @success = I18n.t(:success_text, scope: 'notes.create')
    else
      @errors = note.errors
    end
  end
end
