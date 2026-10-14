# frozen_string_literal: true

# Creates a request in the CitySDK interface of the backoffice for each selected service
class RequestSubmission
  attr_reader :ids, :errors, :create_message, :service

  def initialize(payload, email:)
    @payload = payload
    @email = email
    @ids = []
    @errors = []
  end

  # Stops at the first rejected request unless other requests were already created
  def submit(service_codes)
    service_codes.each do |service_code|
      @service ||= Service[service_code]
      break unless submit_service(service_code) || ids.present?
    end
    self
  end

  # Combines the errors of all rejected requests without duplicates
  def merged_errors
    Request.new.errors.tap do |merged|
      errors.flat_map { |error| error.messages.to_a }.each do |key, messages|
        messages.uniq.each { |message| merged.add(key, message) unless merged.added?(key, message) }
      end
    end
  end

  private

  def submit_service(service_code)
    result = post(service_code)
    unless result.is_a?(Net::HTTPCreated)
      errors << result.errors
      return false
    end
    request = Request.new.load(Request.format.decode(result.body))
    @create_message = request.create_message
    ids << request.id
  end

  def post(service_code)
    Request.connection.post(Request.collection_path(nil, api_key: Request.api_key, email: @email),
      Request.format.encode(@payload.merge(service_code: service_code)))
  rescue ActiveResource::ResourceInvalid => e
    e.base_object_with_errors
  end
end
