# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html


resources :issues_inline, only: [:index] do
  member do
    put :update
  end

end

