# frozen_string_literal: true

class ProtocolsController < ApplicationController
  include RequestFeedback

  def new
    load_request
    @protocol = Protocol.new(message_number: @request.id, user: @user ? @user.name : '')
    render_new_form
  end

  def create
    ProtocolMailer.protocol(Protocol.new(protocol_params)).deliver_now
    @redirect = request_path(params[:request_id], id_list: params[:protocol][:id_list], mobile: context.mobile? || nil)
    @success = I18n.t('protocols.create.success_text')
    render "/application/#{context}/create"
  end

  private

  def protocol_params
    params.expect(protocol: [:user, :process_number, :message_number, :text, { attachments: [] }])
  end
end
