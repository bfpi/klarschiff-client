module ApplicationHelper

  def map_icon(icon)
    overlay_path = "overlay/#{icon}"
    asset_exists?(overlay_path) ? overlay_path : "icons/map/active/png/#{ icon }"
  end

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

  private
  def asset_exists?(path)
    if Rails.configuration.assets.compile
      Rails.application.precompiled_assets.include? path
    else
      Rails.application.assets_manifest.assets[path].present?
    end
  end
end
