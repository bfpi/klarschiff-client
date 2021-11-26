# frozen_string_literal: true

module StatisticsHelper
  def start_dates
    ret = []
    ret << tag.option(t('.12months'), value: l(Date.today - 12.months))
    ret << tag.option(t('.6months'), value: l(Date.today - 6.months))
    ret << tag.option(t('.3months'), value: l(Date.today - 3.months))
    ret << tag.option(t('.1months'), value: l(Date.today - 1.month))
    ret << tag.option(t('.1week'), value: l(Date.today - 1.week))
    ret.join.html_safe
  end

  def service_list
    tmp = {}
    Service.collection.to_a.each do |service|
      group = "#{service.group} (#{I18n.t "service.types.#{service.type}.one"})"
      tmp[group] = [] if tmp[group].blank?
      tmp[group] << tag.option(service.service_name, value: service.service_code)
    end

    ret = []
    tmp.each do |label, groups|
      ret << tag.optgroup(groups.join.html_safe, { label: label })
    end

    ret.join
  end
end
