class NotesController < ApplicationController
  def new
    @request = Request.find(params[:request_id])
    @note = Note.new(service_request_id: @request.id, comment: nil)
    @id_list = params[:id_list].try(:map, &:to_i).presence
    respond_to do |format|
      format.html { head :forbidden }
      format.js { render "/application/#{ context }/new" }
    end
  end

  def create
    result =
      begin
        note = Note.create(params.require(:note).permit(:comment).merge(
          service_request_id: params[:request_id], author: display?(:email) ? params[:author] : @user.email,
          api_key: Note.api_key))
      rescue ActiveResource::ForbiddenAccess => e
        e.base_object_with_errors
      end
    if result.errors.blank?
      @redirect = request_path(params[:request_id], id_list: params[:note][:id_list], mobile: @mobile).html_safe
      if note.persisted?
        @success = I18n.t(:success_text, scope: 'notes.create')
      else
        @errors = note.errors
      end
    else
      @errors = result.errors
    end
    render "/application/#{ context }/create"
  end
end
