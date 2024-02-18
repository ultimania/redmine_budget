class BudgetsController < ApplicationController
  include IssueDataFetcher
  include QueriesHelper

  before_action :find_project

  def index
    # @budgets = @project.budgets
    # @budgets = Budget.find(:all) # @project.budgets
    @budgets = Budget.all
    @cfg_param = {}
    @selectable_assignees = selectable_assignee_list(@project)
    @cfg_param[:basis_date] = Date.today
    @year ||= User.current.today.year
    @month ||= User.current.today.month
    @calendar = Calendar.new(Date.civil(@year, @month, 1), current_language, :month)
    retrieve_query
    @query.group_by = nil
    @query.sort_criteria = nil
    @user = "#{User.current.lastname} #{User.current.firstname}"
    p(@user)
    return unless @query.valid?

    events = []
    events +=
      @query.issues(
        include: %i[tracker assigned_to priority],
        conditions: [
          '((start_date BETWEEN ? AND ?) OR (due_date BETWEEN ? AND ?))',
          @calendar.startdt, @calendar.enddt,
          @calendar.startdt, @calendar.enddt
        ]
      )
    events +=
      @query.versions(
        conditions: [
          'effective_date BETWEEN ? AND ?',
          @calendar.startdt, @calendar.enddt
        ]
      )
    @calendar.events = events
  end

  private

  def find_project
    # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
