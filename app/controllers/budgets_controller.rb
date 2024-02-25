class BudgetsController < ApplicationController
  include IssueDataFetcher
  include QueriesHelper

  before_action :find_project

  def index
    @budgets = Budget.all
    @cfg_param = {}
    @selectable_assignees = selectable_assignee_list(@project)

    # Get from Params
    @cfg_param[:basis_date] = params[:basis_date]
    @cfg_param[:selected_assignee_id] = params[:selected_assignee_id]

    # Create calender object
    year ||= User.current.today.year
    month ||= User.current.today.month
    @calendar = Calendar.new(
      Date.civil(year, month, 1),
      current_language,
      :month
    )
    retrieve_query
    @query.group_by = nil
    @query.sort_criteria = nil
    return unless @query.valid?

    # Get events and time entries each of assignee
    events = []
    return unless @cfg_param[:selected_assignee_id]

    # Get events
    events = @query.issues(
      include: %i[tracker assigned_to priority],
      conditions: [
        '((start_date BETWEEN ? AND ?) OR (due_date BETWEEN ? AND ?))',
        @calendar.startdt, @calendar.enddt,
        @calendar.startdt, @calendar.enddt
      ]
    )
    @calendar.events = events

    # Get time entries
    time_entries = TimeEntry.where(user_id: @cfg_param[:selected_assignee_id])
    @calendar.time_entries = time_entries
  end

  private

  def find_project
    # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
