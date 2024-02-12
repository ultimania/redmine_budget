# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get 'budgets', :to => 'budgets#index'
post 'post/:id/vote', :to => 'budgets#vote'
