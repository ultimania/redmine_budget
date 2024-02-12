#require_dependency 'redmine_budget_hook_listener'

Redmine::Plugin.register :redmine_budget do
  name 'Budget Management plugin'
  author 'Takumi Fukaya'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'https://github.com/ultimania/redmine_budget'
  author_url 'https://github.com/ultimania'
  # menu :project_menu, :budgets, { :controller => 'budgets', :action => 'index' }, :caption => 'Budget'
  permission :budgets, { :budgets => [:index] }, :public => true
  # permission :view_redmine_budget, :redmine_budget => :index
  # permission :vote_redmine_budget, :redmine_budget => :vote
  project_module :budgets do
    permission :view_budgets, :budgets => :index
  end
  menu :project_menu, :budgets, { :controller => 'budgets', :action => 'index' }, :caption => 'Budget', :after => :activity, :param => :project_id
end
