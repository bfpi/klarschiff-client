# frozen_string_literal: true

# Shared steps of the controllers for feedback on a single request, e.g. abuses, comments or votes
module RequestFeedback
  extend ActiveSupport::Concern

  private

  def load_request
    @request = Request.find(params.expect(:request_id))
    @id_list = id_list_param
  end

  def feedback_author
    login_required? ? @user.email : nil
  end

  # The form for new feedback is only available as JS
  def render_new_form
    respond_to do |format|
      format.html { head :forbidden }
      format.js { render "/application/#{context}/new" }
    end
  end

  def request_redirect_path
    request_path(params[:request_id], id_list: params[controller_name.singularize][:id_list], mobile: @mobile)
  end

  # Shows the errors of the backoffice in the form again on desktop
  def render_create_result(feedback)
    @errors = feedback.errors unless feedback.persisted?
    return render "/application/#{context}/create" unless context.desktop? && @errors.present?

    @errors = Array.wrap(@errors).map(&:messages)
    render 'application/desktop/new'
  end
end
