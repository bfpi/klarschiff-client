module ApplicationHelper

  def statistic_current_count
    Request.count(also_archived: false, detailed_status: states, keyword: 'problem, idea')
  end

  def statistic_overall_count
    Request.count(also_archived: true, detailed_status: states, keyword: 'problem, idea')
  end

  def statistic_newest_count
    Request.count(also_archived: true, detailed_status: states, keyword: 'problem, idea',
                                  start_date: Date.today - 30)
  end

  def statistic_processed_count
    Request.count(also_archived: true, detailed_status: 'PROCESSED', keyword: 'problem, idea',
                                     start_date: Date.today - 30)
  end

  def states
   Settings::Map.default_requests_states.strip.split(', ').select { |s| s != 'PENDING' }.join(', ')
  end
end
