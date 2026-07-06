# frozen_string_literal: true

class ProtocolMailer < ActionMailer::Base
  default from: Settings::ProtocolMail.sender

  def protocol(protocol)
    if protocol.attachments
      protocol.attachments.each do |attachment|
        attachments[attachment.original_filename] = File.read(attachment.tempfile) if attachment.present?
      end
    end
    @protocol = protocol
    mail to: Settings::ProtocolMail.recipient, subject: t('kod_protocol_from_user', user: protocol.user)
  end
end
