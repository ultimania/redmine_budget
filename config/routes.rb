# routing
Rails.application.routes.draw do
  resources :projects do
    resources :budgets
  end
end
