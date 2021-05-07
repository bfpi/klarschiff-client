class ConfirmationsController < ApplicationController

  def issue
    confirm(nil, params[:confirmation_id])
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
    @uri = URI(uri.join('/'))
    request = Net::HTTP::Put.new(@uri.path, initheader = {'Content-Type' =>'application/json'})
    response = Net::HTTP.new(@uri.host, @uri.port).start {|http| http.request(request) }
    json = JSON.parse(JSON.parse(response.read_body.to_json))
    return render_error if json.blank? || (json.first.is_a?(Hash) && json.first['code'].present?)
    @request = Request.find(json['service_request_id'].to_i)
    render_success
  end

  def render_error
    render template: 'confirmations/error'
  end

  def render_success
    render template: 'confirmations/success'
  end

end
