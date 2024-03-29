class Protocol
  extend ActiveModel::Naming
  extend ActiveModel::Translation

  include ActiveModel::Conversion

  attr_accessor :user, :process_number, :message_number, :text, :attachments

  def initialize(hash = {})
    hash.each do |k,v|
      self.send(:"#{ k }=", v)
    end
  end

  def persisted?
    false
  end
end
