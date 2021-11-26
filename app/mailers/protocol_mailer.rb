# frozen_string_literal: true

class ProtocolMailer < ApplicationMailer
  default from: Settings::ProtocolMail.sender

  def protocol(protocol)
    protocol.attachments&.each do |attachment|
      attachments[attachment.original_filename] = File.read(attachment.tempfile) if attachment.present?
    end
    @protocol = protocol
    mail to: Settings::ProtocolMail.recipient, subject: "KOD-Protokoll von #{protocol.user}"
  end
end
