module RequestsHelper
  def mark_trust(request)
    content_tag(:span, class: 'label label-default') do 
      content_tag(:span) do
        (request.extended_attributes.trust - 1).times do
          concat content_tag(:span, nil, class: 'glyphicon glyphicon-star', "aria-hidden" => true)
        end
      end
    end
  end

  def mark_photo_required(request)
    content_tag(:span, class: 'label label-default') do 
      content_tag :span, nil, class: 'glyphicon glyphicon-camera', "aria-hidden" => true
    end if request.extended_attributes.photo_required
  end

  def status(request)
    status = t(request.extended_attributes.detailed_status.downcase, scope: :status)
    if date = request.extended_attributes.detailed_status_datetime
      status << " (#{ t('requests.status.since') } #{ l(date.to_date) })"
    end
    status << ", #{ t('requests.status.currently') } #{ request.agency_responsible }"
  end
end
