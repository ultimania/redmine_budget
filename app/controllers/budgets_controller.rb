class BudgetsController < ApplicationController
  include IssueDataFetcher
  before_action :find_project

  def index
    # Base variables
    @selectable_assignees = selectable_assignee_list(@project)

    # Get from Params
    @users = params[:selected_assignee_id]
    if params[:year] and params[:year].to_i > 1900
      @year = params[:year].to_i
      @month = params[:month].to_i if params[:month] and params[:month].to_i > 0 and params[:month].to_i < 13
    end
    @year ||= User.current.today.year
    @month ||= User.current.today.month

    # Create Calendar object
    @calendar = Calendar.new(Date.civil(@year, @month, 1), @users, :month)
  end

  private

  def find_project
    # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
