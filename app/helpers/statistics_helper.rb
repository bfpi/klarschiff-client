# frozen_string_literal: true

module StatisticsHelper
  START_DATES = { '12months' => 12.months, '6months' => 6.months, '3months' => 3.months, '1months' => 1.month,
                  '1week' => 1.week }.freeze

  def start_dates
    safe_join(START_DATES.map do |key, period|
      content_tag('option', t(".#{key}"), value: l(Time.zone.today - period))
    end)
  end

  def service_list
    groups = Service.collection.to_a.group_by do |service|
      "#{service.group} (#{I18n.t "service.types.#{service.type}.one"})"
    end
    safe_join(groups.map do |label, services|
      content_tag('optgroup', safe_join(services.map do |s|
        content_tag('option', s.service_name, value: s.service_code)
      end),
        { label: label })
    end)
  end
end
