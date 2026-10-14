# frozen_string_literal: true

class Service < ApplicationResource
  alias_attribute :category, :group

  delegate :idea?, :problem?, :tipp?, to: :type

  # Loaded on first use instead of when the class is loaded, so that the application also boots with eager loading
  # while the backoffice is not available. The services are kept for the lifetime of the process.
  def self.collection
    @collection ||= all.to_a
  end

  def self.[](code)
    collection.find { |s| s.service_code.to_s == code.to_s }
  end

  def to_s
    service_name
  end

  def type
    return nil unless keywords

    keyword = (t = keywords.split(';').first) && case t
                                                 when 'idee'
                                                   'idea'
                                                 when 'tipp'
                                                   'tip'
                                                 else
                                                   t
                                                 end
    ActiveSupport::StringInquirer.new keyword
  end

  def as_json(options = {})
    super(options.merge(only: %i[service_code service_name photo_requested], methods: %i[type category]))
  end
end
