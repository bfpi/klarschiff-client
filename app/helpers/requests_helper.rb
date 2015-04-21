module RequestsHelper
  def mark_trust(request)
    trust = request.extended_attributes.trust - 1
    content_tag(:span, class: 'label label-default') do 
      content_tag(:span) do
        trust.times do
          concat content_tag(:span, nil, class: 'glyphicon glyphicon-star', "aria-hidden" => true)
        end
      end
    end if trust > 0
  end

  def mark_photo_required(request)
    content_tag(:span, class: 'label label-default') do 
      content_tag :span, nil, class: 'glyphicon glyphicon-camera', "aria-hidden" => true
    end if request.extended_attributes.photo_required
  end

  def status(request)
    status = t(request.detailed_status.downcase, scope: :status)
    if date = request.extended_attributes.detailed_status_datetime
      status << " (#{ t('requests.status.since') } #{ l(date.to_date) })"
    end
    status << ", #{ t('requests.status.currently') } #{ request.agency_responsible }"
  end

  def statuses
    %w(pending received in_process processed rejected).map { |st|
      [t(st, scope: :status), st.upcase]
    }
  end

  def categories(type, current)
    options_for_select(Service.collection.select { |s| s.type == type }.map(&:group).uniq.sort,
                       current)
  end

  def services(category)
    Service.collection.select { |s| s.group == category }.map { |s|
      [s.service_name, s.service_code]
    }.insert 0, [t('placeholder.select.service'), disabled: true, style: "display: none"]
  end
end
