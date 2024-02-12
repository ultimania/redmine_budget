class BudgetsController < ApplicationController
  include IssueDataFetcher

  before_action :find_project, :authorize, :only => :index

  def index
    @project = Project.find(params[:project_id])
    # @budgets = @project.budgets
    # @budgets = Budget.find(:all) # @project.budgets
    @budgets = Budget.all
    @cfg_param = {}
    @selectable_assignees = selectable_assignee_list(@project)
    @cfg_param[:basis_date] = Date.today

  end

  private

  def find_project
    # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:project_id])
  end
end