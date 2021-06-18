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
    uri = ['requests']
    uri << action unless action.blank?
    uri << confirmation_id
    uri << 'confirm.json'
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
    logger.debug uri.inspect
    request = Net::HTTP::Put.new(uri.path, 'Content-Type' => 'application/json')
    logger.debug request.inspect
    logger.debug request['Content-Type'].inspect
    if (proxy = ENV['HTTP_PROXY'] || ENV['http_proxy']).present? # Workaround for open-uri https-proxy problem
      proxy = "http://#{proxy}" unless proxy.match(%r{^https?://})
      p_uri = URI.parse(proxy)
      Net::HTTP.Proxy p_uri.host, p_uri.port
    else
      Net::HTTP
    end.new(uri.host, uri.port).start { |http| http.request request }
  end

  def render_error(template_prefix)
    render template: "confirmations/#{template_prefix}_error"
  end

  def render_success(template_prefix)
    render template: "confirmations/#{template_prefix}_success"
  end

end
