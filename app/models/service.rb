# frozen_string_literal: true

class Service < ActiveResource::Base
  include ResourceClient
  set_server_connection :city_sdk

  cattr_reader :collection, instance_reader: false do
    Service.all.to_a
  end

  alias_attribute :category, :group

  def self.[](code)
    collection.find { |s| s.service_code.to_s == code.to_s }
  end

  def to_s
    service_name
  end

  def type
    return nil unless keywords
    ActiveSupport::StringInquirer.new (t = keywords.split(';').first) && case t
                                                                         when 'idee'
                                                                           'idea'
                                                                         when 'tipp'
                                                                           'tip'
                                                                         else
                                                                           t
                                                                         end
  end

  delegate :idea?, to: :type

  delegate :problem?, to: :type

  delegate :tipp?, to: :type

  def as_json(options = {})
    super options.merge(only: %i[service_code service_name], methods: %i[type category])
  end
end
