# Simple class to compute the start and end dates of a calendar
class Calendar
  include Redmine::Utils::DateCalculation
  include IssueDataFetcher

  attr_reader :startdt, :enddt, :time_entries, :events, :day_of_week

  def initialize(date, users, period = :month)
    @day_of_week = %w[Non Mon Tue Wed Thu Fri Sat Sun]
    @date = date
    @users = users.present? ? users.map(&:to_i) : users
    @ending_events_by_days = {}
    @starting_events_by_days = {}
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
    @events = issues_by_duration(@startdt, @enddt)
    @time_entries = TimeEntry.where(user_id: @users)
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

  def nwdays_count(start_date, end_date)
    (start_date..end_date).to_a.count do |day|
      non_working_week_days.include?(day.cwday)
    end
  end

  def total_estimated_hours_by_day(user = nil, day = nil)
    # return 0 when non working day
    return 0.0 if day.present? && non_working_week_days.include?(day.cwday)

    events = day.present? ? events_on(day) : @events
    users = user.present? ? [user.to_i] : @users
    events_by_user = events.select do |event|
      if users.present?
        users.include?(event.assigned_to_id)
      else
        event.assigned_to_id == -1
      end
    end
    return 0.0 unless events_by_user.present?

    events_by_user.sum do |event_by_user|
      duration = event_by_user.duration - nwdays_count(event_by_user.start_date, event_by_user.due_date) + 1
      day.present? ? event_by_user.total_estimated_hours.to_f / duration : event_by_user.total_estimated_hours.to_f
    end
  end

  def total_time_entries(user = nil, day = nil)
    users = user.present? ? [] : @users
    conditions = { user_id: users }
    conditions[:spent_on] = day if day.present?

    @time_entries
      .where(conditions)
      .sum(:hours)
      .to_f
  end
end
