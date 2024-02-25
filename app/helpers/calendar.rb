# frozen_string_literal: true

# Redmine - project management software
# Copyright (C) 2006-2023  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# Simple class to compute the start and end dates of a calendar
class Calendar
  include Redmine::Utils::DateCalculation
  attr_reader :startdt, :enddt
  attr_writer :time_entries, :events

  def initialize(date, _lang = current_language, period = :month)
    @date = date
    @events = []
    @time_entries = []
    @ending_events_by_days = {}
    @starting_events_by_days = {}
    # set_language_if_valid lang
    case period
    when :month
      @startdt = Date.civil(date.year, date.month, 1)
      @enddt = (@startdt >> 1) - 1
    when :week
      @startdt = date - (date.cwday - first_wday) % 7
      @enddt = date + (last_wday - date.cwday) % 7
    else
      raise 'Invalid period'
    end
  end

  def format_month
    (@startdt..@enddt).to_a
  end

  def week_number(day)
    (day + (11 - day.cwday) % 7).cweek
  end

  def day_css_classes(day)
    css = day.month == month ? +'even' : +'odd'
    css << ' today' if User.current.today == day
    css << ' nwday' if non_working_week_days.include?(day.cwday)
    css
  end

  # Returns events for the given day
  def events_on(day)
    @events.select do |event|
      event.due_date.present? && event.start_date.present? && (event.due_date >= day) && (event.start_date <= day)
    end
  end

  # Calendar current month
  def month
    @date.month
  end

  # Return the first day of week
  # 1 = Monday ... 7 = Sunday
  def first_wday
    @first_dow ||= case Setting.start_of_week.to_i
                   when 1
                     (1 - 1) % 7 + 1
                   when 6
                     (6 - 1) % 7 + 1
                   when 7
                     (7 - 1) % 7 + 1
                   else
                     (7 - 1) % 7 + 1
                   end
  end

  def last_wday
    @last_dow ||= (first_wday + 5) % 7 + 1
  end

  def total_estimated_hours(user, day = nil)
    events = day.present? ? events_on(day) : @events
    issues = events.select do |event|
      event.assigned_to_id == user.to_i
    end
    return 0.0 unless issues.present?

    issues.sum do |issue|
      duration = issue.duration.zero? ? 1 : issue.duration
      result = day.nil? ? issue.total_estimated_hours.to_f : issue.total_estimated_hours.to_f / duration
    end
  end

  def total_time_entries(user, day = nil)
    conditions = { user_id: user }
    conditions[:spent_on] = day if day.present?

    @time_entries
      .where(conditions)
      .sum(:hours)
      .to_f
  end
end
