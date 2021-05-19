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

  private

  def confirm(action, confirmation_id)
    uri = [Settings::ResourceServer.city_sdk[:site], 'requests']
    uri << action unless action.blank?
    uri << confirmation_id
    uri << 'confirm.json'
    json = JSON.parse(JSON.parse(call(uri).read_body.to_json))
    return render_error(:confirm) if json.blank? || (json.first.is_a?(Hash) && json.first['code'].present?)
    @request = Request.find(json['service_request_id'].to_i)
    render_success(:confirm)
  end

  def revoke(confirmation_id)
    uri = [Settings::ResourceServer.city_sdk[:site], 'requests']
    uri << confirmation_id
    uri << 'revoke.json'
    json = JSON.parse(JSON.parse(call(uri).read_body.to_json))
    return render_error(:revoke) if json.blank? || (json.first.is_a?(Hash) && json.first['code'].present?)
    render_success(:revoke)
  end

  def call(uri)
    @uri = URI(uri.join('/'))
    request = Net::HTTP::Put.new(@uri.path, initheader = {'Content-Type' =>'application/json'})
    response = Net::HTTP.new(@uri.host, @uri.port).start {|http| http.request(request) }
    response
  end

  def render_error(template_prefix)
    render template: "confirmations/#{template_prefix}_error"
  end

  def render_success(template_prefix)
    render template: "confirmations/#{template_prefix}_success"
  end

end
