class ProtocolMailer < ActionMailer::Base
  default from: Settings::ProtocolMail.sender

  def protocol(protocol)
    protocol.attachments.each do |attachment|
      attachments[attachment.original_filename] = File.read(attachment.tempfile) unless attachment.blank?
    end if protocol.attachments
    @protocol = protocol
    mail to: Settings::ProtocolMail.recipient, subject: t('kod_protocol_from_user', user: protocol.user)
  end
end
