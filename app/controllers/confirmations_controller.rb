class ConfirmationsController < ApplicationController

  def issue
    confirm(nil, params[:confirmation_id])
  end

  def issue_with_photo
    confirm(nil, params[:confirmation_id], with_photo: true)
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

  private

  def confirm(action, confirmation_id, with_photo: false)
    uri = ['requests']
    uri << action unless action.blank?
    uri << confirmation_id
    uri << "confirm#{'_with_photo' if with_photo}.json"
    json = JSON.parse(JSON.parse(call(uri.join('/')).read_body.to_json))
    return render_error(:confirm) if json.blank? || (json.first.is_a?(Hash) && json.first['code'].present?)
    @request = Request.find(json['service_request_id'].to_i)
    render_success(:confirm)
  end

  def revoke(confirmation_id)
    uri = "requests/#{confirmation_id}/revoke.json"
    json = JSON.parse(JSON.parse(call(uri).read_body.to_json))
    return render_error(:revoke) if json.blank? || (json.first.is_a?(Hash) && json.first['code'].present?)
    render_success(:revoke)
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
