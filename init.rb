#require_dependency 'redmine_budget_hook_listener'

Redmine::Plugin.register :redmine_budget do
  name 'Budget Management plugin'
  author 'Takumi Fukaya'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'https://github.com/ultimania/redmine_budget'
  author_url 'https://github.com/ultimania'
  menu :application_menu, :redmine_budget, { :controller => 'redmine_budget', :action => 'index' }, :caption => 'Polls'
  # permission :redmine_budget, { :redmine_budget => [:index, :vote] }, :public => true
  # permission :view_redmine_budget, :redmine_budget => :index
  # permission :vote_redmine_budget, :redmine_budget => :vote
  project_module :redmine_budget do
    permission :view_redmine_budget, :redmine_budget => :index
    permission :vote_redmine_budget, :redmine_budget => :vote
  end
  menu :project_menu, :redmine_budget, { :controller => 'redmine_budget', :action => 'index' }, :caption => 'Polls', :after => :activity, :param => :project_id
end
