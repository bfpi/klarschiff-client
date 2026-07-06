# frozen_string_literal: true

class Service < ApplicationResource

  cattr_reader :collection, instance_reader: false do
    Service.all.to_a
  end

  alias_attribute :category, :group

  delegate :idea?, :problem?, :tipp?, to: :type

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
    super(options.merge(only: %i[service_code service_name], methods: %i[type category]))
  end
end
