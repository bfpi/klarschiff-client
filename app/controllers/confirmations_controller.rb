# frozen_string_literal: true

class ConfirmationsController < ApplicationController
  def issue
    confirm(nil, params[:confirmation_id])
  end

  def revoke_issue
    revoke(params[:confirmation_id])
  end

  def vote
    confirm('votes', params[:confirmation_id])
  end

  def abuse
    confirm('abuses', params[:confirmation_id])
  end

  def photo
    confirm('photos', params[:confirmation_id])
  end

  def completion
    confirm('completions', params[:confirmation_id])
  end

  private

  def confirm(action, confirmation_id)
    json = backoffice_response(['requests', action.presence, confirmation_id, 'confirm.json'].compact.join('/'))
    return render_error(:confirm) if rejected?(json)

    @request = Request.find(json['service_request_id'].to_i)
    render_success(:confirm)
  end

  def revoke(confirmation_id)
    return render_error(:revoke) if rejected?(backoffice_response("requests/#{confirmation_id}/revoke.json"))

    render_success(:revoke)
  end

  def backoffice_response(path)
    JSON.parse(call(path).read_body)
  end

  # The backoffice answers with a list of errors if the confirmation fails
  def rejected?(json)
    json.blank? || (json.first.is_a?(Hash) && json.first['code'].present?)
  end

  def call(path)
    uri = URI.join(Settings::ResourceServer.city_sdk[:site], path)
    request = Net::HTTP::Put.new(uri.path, 'Content-Type' => 'application/json')
    Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
  end

  def render_error(template_prefix)
    render template: "confirmations/#{template_prefix}_error"
  end

  def render_success(template_prefix)
    render template: "confirmations/#{template_prefix}_success"
  end
end
