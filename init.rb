# require_dependency 'redmine_budget_hook_listener'

Redmine::Plugin.register :redmine_budget do
  name 'Budget Management plugin'
  author 'Takumi Fukaya'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'https://github.com/ultimania/redmine_budget'
  author_url 'https://github.com/ultimania'

  project_module :budgets do
    permission :view_budgets, budgets: :index, require: :member
  end

  menu :project_menu, :budgets, { controller: :budgets, action: :index },
       caption: :tab_display_name, after: :activity, param: :project_id
end
