# frozen_string_literal: true

require 'test_helper'

class StatisticsHelperTest < ActionView::TestCase
  test 'start_dates offers the periods of the statistic' do
    travel_to Date.new(2024, 3, 31) do
      @virtual_path = 'statistics/_index'

      assert_equal '<option value="31.03.2023">12 Monate</option><option value="30.09.2023">6 Monate</option>' \
                   '<option value="31.12.2023">3 Monate</option><option value="29.02.2024">1 Monat</option>' \
                   '<option value="24.03.2024">1 Woche</option>', start_dates
    end
  end

  test 'start_dates is html safe' do
    @virtual_path = 'statistics/_index'

    assert_predicate start_dates, :html_safe?
  end

  test 'service_list groups the services by category and type' do
    services = [Service.new(service_payload(4)), Service.new(service_payload(5, service_name: 'Müll & Schrott')),
                Service.new(service_payload(6, group: 'Ideen', keywords: 'idea'))]

    Service.stub(:collection, services) do
      assert_equal '<optgroup label="Gefahrenstellen (Problem)"><option value="4">bauliche Gefahrenstelle</option>' \
                   '<option value="5">Müll &amp; Schrott</option></optgroup>' \
                   '<optgroup label="Ideen (Idee)"><option value="6">bauliche Gefahrenstelle</option></optgroup>',
        service_list
    end
  end
end
