class BudgetsController < ApplicationController
  include IssueDataFetcher

  before_action :find_project

  def index
    @budgets = Budget.all
    @cfg_param = {}
    @selectable_assignees = selectable_assignee_list(@project)

    # Get from Params
    @cfg_param[:basis_date] = params[:basis_date]
    @cfg_param[:selected_assignee_id] = params[:selected_assignee_id]
    if params[:year] and params[:year].to_i > 1900
      @year = params[:year].to_i
      @month = params[:month].to_i if params[:month] and params[:month].to_i > 0 and params[:month].to_i < 13
    end
    @year ||= User.current.today.year
    @month ||= User.current.today.month
    @calendar = Calendar.new(
      Date.civil(@year, @month, 1),
      current_language,
      :month
    )

    # Get events and time entries each of assignee
    events = []
    return unless @cfg_param[:selected_assignee_id]

    events = issues_by_duration(@calendar.startdt, @calendar.enddt)
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
