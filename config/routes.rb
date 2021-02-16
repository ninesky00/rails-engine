Rails.application.routes.draw do
  namespace :api do 
    namespace :v1 do 
      resources :merchants
      scope module: 'merchants', path: 'merchants/:id', as: 'merchants' do 
        resources :items, only: [:index]
      end
      resources :items
    end
  end
end
