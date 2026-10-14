# frozen_string_literal: true

module ObservationsHelper
  def service_names(type)
    Service.where(extended: true).select { |s| s.type == type }.map { |s| { id: s.group_id, name: s.group } }.uniq
  end

  def service_name(code)
    Service.find(code)
  end

  # Description of a request in the feed of the observations
  def feed_description(request)
    rows = { status: status(request), status_notes: request.status_notes.presence || t('.status_notes_not_available'),
             votes: request.votes.positive? ? request.votes : t('.no_votes'), description: request.description,
             media_url: feed_image(request) }
    safe_join(rows.map { |attribute, value| feed_row(attribute, value) } << feed_link(request))
  end

  private

  def feed_link(request)
    link_to(t('.link', name: Settings::Client.name), Settings::Url.ks_server_url + map_path(request: request),
      target: '_blank', rel: 'noopener')
  end

  def feed_row(attribute, value)
    safe_join([content_tag(:b, "#{Request.human_attribute_name(attribute)}:"), ' ', value, tag.br])
  end

  def feed_image(request)
    return t('.img_not_available') if (url = request.media_url).blank?

    safe_join([tag.br, image_tag(url, alt: Request.human_attribute_name(:media_url), class: 'rounded img-fluid')])
  end
end
